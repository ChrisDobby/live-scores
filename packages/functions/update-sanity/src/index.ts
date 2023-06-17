import sanity from '@sanity/client';
import { format, add } from 'date-fns';
import { validateGameOver } from '@cleckheaton-ccc-live-scores/schema';

const sanityClient = sanity({ token: process.env.SANITY_AUTH_TOKEN, apiVersion: '2021-03-25', dataset: 'production', projectId: 'dq0grzvl', useCdn: false });

const updateGameOver = (fixture, result, scorecard) => sanityClient.patch(fixture).set({ result, scorecard }).commit();

const sanityTeamName = {
  firstTeam: '1st',
  secondTeam: '2nd',
};

const updateSanity = async (gameOverMessage: unknown) => {
  const { teamName, url, result } = validateGameOver(gameOverMessage);

  const fromMatchDate = format(new Date(), 'yyyy-MM-dd');
  const toMatchDate = format(add(new Date(), { days: 1 }), 'yyyy-MM-dd');
  const fixtures = await sanityClient.fetch(`*[_type == "fixture" && matchDate >= "${fromMatchDate}" && matchDate <= "${toMatchDate}" && team == "${sanityTeamName[teamName]}"]`);
  if (!fixtures.length) {
    console.log('no fixtures found', fromMatchDate, toMatchDate, sanityTeamName[teamName]);
    return;
  }

  return Promise.all(fixtures.map(fixture => updateGameOver(fixture._id, result, url)));
};

export const handler = async ({ Records }) => {
  console.log(JSON.stringify(Records, null, 2));
  await Promise.all(Records.map(({ Sns: { Message } }) => updateSanity(JSON.parse(Message))));
};
