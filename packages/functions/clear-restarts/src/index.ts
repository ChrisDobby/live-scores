import { validateGameOver, validateRestartSchedule } from '@cleckheaton-ccc-live-scores/schema';
import { SQSClient, SendMessageCommand } from '@aws-sdk/client-sqs';

const sqsClient = new SQSClient({ region: 'eu-west-2' });

const restartScheduleQueueUrl = `${process.env.RESTART_SCHEDULE_QUEUE_URL}`;

const clearRestarts = async (gameOverMessage: unknown) => {
  const { teamName } = validateGameOver(gameOverMessage);

  return sqsClient.send(
    new SendMessageCommand({
      QueueUrl: restartScheduleQueueUrl,
      MessageBody: JSON.stringify(
        validateRestartSchedule({
          type: 'clear',
          teamName,
        }),
      ),
    }),
  );
};

export const handler = async ({ Records }) => {
  console.log(JSON.stringify(Records, null, 2));
  await Promise.all(Records.map(({ Sns: { Message } }) => clearRestarts(JSON.parse(Message))));
};
