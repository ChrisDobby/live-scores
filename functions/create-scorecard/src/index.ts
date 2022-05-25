import * as cheerio from 'cheerio';
import { S3Client, PutObjectCommand } from '@aws-sdk/client-s3';

const s3Client = new S3Client({});

type BowlingFigures = {
  name: string;
  overs: string;
  maidens: string;
  runs: string;
  wickets: string;
  wides: string;
  noBalls: string;
  economyRate: string;
};

type PlayerInnings = {
  name: string;
  runs: string;
  balls: string;
  minutes: string;
  fours: string;
  sixes: string;
  strikeRate: string;
  howout: string[];
};

type Innings = {
  batting: {
    innings: PlayerInnings[];
    extras: string;
    total: string;
  };
  fallOfWickets: string;
  bowling: BowlingFigures[];
};

const {
  FIRST_TEAM_QUEUE_ARN: firstTeamQueueArn,
  SECOND_TEAM_QUEUE_ARN: secondTeamQueueArn,
  SCORECARD_BUCKET_NAME: bucketName,
} = process.env;

const keyName = {
  [`${firstTeamQueueArn}`]: 'firstTeam.json',
  [`${secondTeamQueueArn}`]: 'secondTeam.json',
};

const getBowlingFigures = ($, row) => {
  const name = $('.nvp-scorecard__bowler', row).first().text();
  const overs = $('.nvp-scorecard__overs', row).first().text();
  const maidens = $('.nvp-scorecard__maidens', row).first().text();
  const runs = $('.nvp-scorecard__runs', row).first().text();
  const wickets = $('.nvp-scorecard__wickets', row).first().text();
  const wides = $('.nvp-scorecard__wides', row).first().text();
  const noBalls = $('.nvp-scorecard__no-balls', row).first().text();
  const economyRate = $('.nvp-scorecard__economy-rate', row).first().text();

  return {
    name,
    overs,
    maidens,
    runs,
    wickets,
    wides,
    noBalls,
    economyRate,
  };
};

const getBowling = ($, bowlingTable) => {
  const bowlingFigures: BowlingFigures[] = [];
  const bowlingRows = $('.nvp-scorecard__table-row', bowlingTable);
  for (const row of bowlingRows) {
    bowlingFigures.push(getBowlingFigures($, row));
  }

  return bowlingFigures;
};

const getFallOfWickets = ($, fowTable) =>
  $('.nvp-scorecard__fall p', fowTable).first().text();

const getHowoutLine = ($, howoutLine) => {
  if (!howoutLine) {
    return '';
  }

  const text1 = $('.nvp-scorecard__event_icon', howoutLine).text();
  const text2 = $('.nvp-scorecard__event_copy', howoutLine).text();

  return `${text1} ${text2}`.trim();
};

const getHowout = ($, event) => {
  const [howout1, howout2] = event.children();

  return [getHowoutLine($, howout1), getHowoutLine($, howout2)];
};

const getPlayerInnings = ($, playerInnings) => {
  const name = $('.nvp-scorecard__batsmen', playerInnings).first().text();
  const runs = $('.nvp-scorecard__runs', playerInnings).first().text();
  const balls = $('.nvp-scorecard__balls', playerInnings).first().text();
  const minutes = $('.nvp-scorecard__mins', playerInnings).first().text();
  const fours = $('.nvp-scorecard__fours', playerInnings).first().text();
  const sixes = $('.nvp-scorecard__sixes', playerInnings).first().text();
  const strikeRate = $('.nvp-scorecard__strikerate', playerInnings)
    .first()
    .text();
  const event = $('.nvp-scorecard__event', playerInnings);

  return {
    name,
    runs,
    balls,
    minutes,
    fours,
    sixes,
    strikeRate,
    howout: getHowout($, event),
  };
};

const getTotals = ($, totals) => {
  const [extras, total] = totals.children();
  return { extras: $('span', extras).text(), total: $('span', total).text() };
};

const getBatting = ($, batting) => {
  const playerInnings: PlayerInnings[] = [];
  const rows = $('.nvp-scorecard__table-row', batting);
  for (const row of rows) {
    playerInnings.push(getPlayerInnings($, row));
  }

  return {
    innings: playerInnings,
    ...getTotals($, $('.nvp-scorecard__bottom-info--right', batting)),
  };
};

const getInnings = ($, innings) => {
  const [battingTable, fowTable, bowlingTable] = $(
    '.nvp-scorecard__table',
    innings
  );
  const batting = getBatting($, battingTable);
  const fallOfWickets = getFallOfWickets($, fowTable);
  const bowling = getBowling($, bowlingTable);

  return { batting, fallOfWickets, bowling };
};

const getScorecard = (scorecardHtml: string) => {
  const $ = cheerio.load(scorecardHtml);

  const matchInnings: Innings[] = [];

  const inningsDocuments = $('.nvp-innings__tab-content');
  for (const inningsDocument of inningsDocuments) {
    matchInnings.push(getInnings($, inningsDocument));
  }

  return matchInnings;
};

const processRecord = ({ body, eventSourceARN }) => {
  const bucketKey = keyName[eventSourceARN];
  if (!bucketKey) {
    throw new Error('Unexpected eventSourceARN');
  }

  const scorecard = getScorecard(body);
  console.log(scorecard);
  console.log(`writing to ${bucketKey}`);

  const command = new PutObjectCommand({
    Bucket: bucketName,
    Key: bucketKey,
    Body: JSON.stringify(scorecard),
  });
  return s3Client.send(command);
};

export const handler = async ({ Records }) => {
  console.log(Records);
  const result = await Promise.all(Records.map(processRecord));
  console.log(result);
};
