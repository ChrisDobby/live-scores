import * as cheerio from 'cheerio';
import { Scorecard, PlayerInnings, Innings, BowlingFigures, validateScorecard } from '@cleckheaton-ccc-live-scores/schema';

const { FIRST_TEAM_QUEUE_ARN: firstTeamQueueArn, SECOND_TEAM_QUEUE_ARN: secondTeamQueueArn } = process.env;

const teamName = {
  [`${firstTeamQueueArn}`]: 'firstTeam',
  [`${secondTeamQueueArn}`]: 'secondTeam',
};

const getBowlingFigures = ($, row): BowlingFigures => {
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

const getBowling = ($, bowlingTable): BowlingFigures[] => {
  const bowlingFigures: BowlingFigures[] = [];
  const bowlingRows = $('.nvp-scorecard__table-row', bowlingTable);
  for (const row of bowlingRows) {
    bowlingFigures.push(getBowlingFigures($, row));
  }

  return bowlingFigures;
};

const getFallOfWickets = ($, fowTable): string => $('.nvp-scorecard__fall p', fowTable).first().text();

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

const getPlayerInnings = ($, playerInnings): PlayerInnings => {
  const name = $('.nvp-scorecard__batsmen', playerInnings).first().text().trim();
  const runs = $('.nvp-scorecard__runs', playerInnings).first().text();
  const balls = $('.nvp-scorecard__balls', playerInnings).first().text();
  const minutes = $('.nvp-scorecard__mins', playerInnings).first().text();
  const fours = $('.nvp-scorecard__fours', playerInnings).first().text();
  const sixes = $('.nvp-scorecard__sixes', playerInnings).first().text();
  const strikeRate = $('.nvp-scorecard__strikerate', playerInnings).first().text();
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

const getTotals = ($, totals): { extras: string; total: string } => {
  const [extras, total] = totals.children();
  return { extras: $('span', extras).text(), total: $('span', total).text() };
};

const getBatting = ($, batting, team): Innings['batting'] & { team: string } => {
  const playerInnings: PlayerInnings[] = [];
  const rows = $('.nvp-scorecard__table-row', batting);
  for (const row of rows) {
    playerInnings.push(getPlayerInnings($, row));
  }

  return {
    innings: playerInnings,
    ...getTotals($, $('.nvp-scorecard__bottom-info--right', batting)),
    team,
  };
};

const getInnings = ($, innings, team): Innings => {
  const [battingTable, table2, table3] = $('.nvp-scorecard__table', innings);
  const batting = getBatting($, battingTable, team);
  const fallOfWickets = getFallOfWickets($, table2);
  const bowling = getBowling($, fallOfWickets ? table3 : table2);

  return { batting, fallOfWickets, bowling };
};

const getTeamNames = $ => {
  const teams = $('.nvp-innings__tab-team');
  const teamNames: string[] = [];

  for (const team of teams) {
    teamNames.push($(team).text().replace(' CC', '').trim());
  }

  return teamNames;
};

const getResult = (headerHtml: string) => {
  try {
    const $ = cheerio.load(headerHtml);
    const matchStatus = $('.match-status').first().text().trim();
    if (!matchStatus || matchStatus === 'IN PROGRESS') {
      return null;
    }

    const winningTeam = $('.match-status').first().parent().children().first().text().trim();
    return `${winningTeam || ''} ${matchStatus}`.trim();
  } catch (ex) {
    console.log(ex);
    return null;
  }
};

export const getScorecard = (scorecardUrl: string, scorecardHtml: string, headerHtml: string, eventSourceARN: string): Scorecard => {
  const $ = cheerio.load(scorecardHtml);

  const teamNames = getTeamNames($);
  const innings: Innings[] = [];

  const inningsDocuments = $('.nvp-innings__tab-content');
  for (const inningsDocument of inningsDocuments) {
    innings.push(getInnings($, inningsDocument, teamNames[innings.length] || ''));
  }

  return validateScorecard({ url: scorecardUrl, teamName: teamName[eventSourceARN], result: getResult(headerHtml), innings });
};
