import { validateScorecard, validateRestartSchedule } from '@cleckheaton-ccc-live-scores/schema';
import { SQSClient, SendMessageCommand } from '@aws-sdk/client-sqs';
import { add } from 'date-fns';

const sqsClient = new SQSClient({ region: 'eu-west-2' });

const restartScheduleQueueUrl = `${process.env.RESTART_SCHEDULE_QUEUE_URL}`;

const sendRestart = (scorecardMessage: unknown) => {
  const scorecard = validateScorecard(scorecardMessage);
  console.log(scorecard);

  const restartDateTime = add(new Date(), { minutes: 30 });
  return sqsClient.send(
    new SendMessageCommand({
      QueueUrl: restartScheduleQueueUrl,
      MessageBody: JSON.stringify(
        validateRestartSchedule({
          type: 'create',
          restartDateTime,
          teamName: scorecard.teamName,
        }),
      ),
    }),
  );
};

export const handler = async ({ Records }) => {
  console.log(JSON.stringify(Records, null, 2));
  await Promise.all(Records.map(({ Sns: { Message } }) => sendRestart(JSON.parse(Message))));
};
