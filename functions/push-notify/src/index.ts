import { Scorecard, validateScorecard } from '@cleckheaton-ccc-live-scores/schema';
import { getLastPush, updateLastPush } from './s3';
import { publishToSns } from './sns';
import { getUpdate } from './updates';

const handleScorecard = async (scorecard: Scorecard) => {
  const lastPush = await getLastPush(scorecard);
  console.log(lastPush);
  const { updates, push } = getUpdate(scorecard, lastPush);
  await Promise.all(updates.map(update => publishToSns(update)).concat(push ? updateLastPush(scorecard, push) : []));
};

const handleMessage = async (scorecardMessage: unknown) => {
  const scorecard = validateScorecard(scorecardMessage);
  console.log(scorecard);
  if (!scorecard.innings || !scorecard.innings.length) {
    return;
  }

  await handleScorecard(scorecard);
};

export const handler = async ({ Records }) => {
  console.log(JSON.stringify(Records, null, 2));
  await Promise.all(Records.map(({ Sns: { Message } }) => handleMessage(JSON.parse(Message))));
};
