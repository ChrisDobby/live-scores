import sanity from '@sanity/client';
import { format, add } from 'date-fns';
import { get } from './store';

const sanityClient = sanity({ token: process.env.SANITY_AUTH_TOKEN, apiVersion: '2021-03-25', dataset: 'production', projectId: 'dq0grzvl', useCdn: false });

const updateGameOver = (fixture, result, scorecard) => sanityClient.patch(fixture).set({ result, scorecard }).commit();

const sanityTeamName = {
  firstTeam: '1st',
  secondTeam: '2nd',
};

const updateSanity = async scorecard => {
  if (!scorecard.result || !scorecard.teamName) {
    console.log('missing result or teamName', scorecard);
    return;
  }

  const fromMatchDate = format(new Date(), 'yyyy-MM-dd');
  const toMatchDate = format(add(new Date(), { days: 1 }), 'yyyy-MM-dd');
  const fixtures = await sanityClient.fetch(
    `*[_type == "fixture" && matchDate >= "${fromMatchDate}" && matchDate <= "${toMatchDate}" && team == "${sanityTeamName[scorecard.teamName]}"]`,
  );
  if (!fixtures.length) {
    console.log('no fixtures found', fromMatchDate, toMatchDate, sanityTeamName[scorecard.teamName]);
    return;
  }

  const scorecardUrl = (await get(new Date().toDateString()))?.[scorecard.teamName];
  if (!scorecardUrl) {
    console.log('no scorecard url found for', new Date().toDateString(), scorecard.teamName);
    return;
  }

  return Promise.all(fixtures.map(fixture => updateGameOver(fixture._id, scorecard.result, scorecardUrl)));
};

export const handler = async ({ Records }) => {
  console.log(JSON.stringify(Records, null, 2));
  await Promise.all(Records.map(({ Sns: { Message } }) => updateSanity(JSON.parse(Message))));
};
