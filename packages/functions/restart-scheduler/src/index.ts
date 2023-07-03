import { validateRestartSchedule } from '@cleckheaton-ccc-live-scores/schema';
import { handleRestart } from './scheduler';

const processRecord = ({ body }) => {
  const restartSchedule = validateRestartSchedule(JSON.parse(body));
  return handleRestart(restartSchedule);
};

export const handler = async ({ Records }) => {
  console.log(Records);
  await Promise.all(Records.map(processRecord));
};
