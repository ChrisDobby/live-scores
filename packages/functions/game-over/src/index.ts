import { validateScorecard } from '@cleckheaton-ccc-live-scores/schema';
import { publishToSns } from './sns';

const handleMessage = async (scorecardMessage: unknown) => {
  const scorecard = validateScorecard(scorecardMessage);
  console.log(scorecard);
  if (!scorecard.result) {
    return;
  }

  await publishToSns(scorecard);
};

export const handler = async ({ Records }) => {
  console.log(JSON.stringify(Records, null, 2));
  await Promise.all(Records.map(({ Sns: { Message } }) => handleMessage(JSON.parse(Message))));
};
