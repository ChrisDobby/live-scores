import { validateRestartSchedule } from '@cleckheaton-ccc-live-scores/schema';
import { SQSClient, SendMessageCommand } from '@aws-sdk/client-sqs';

const sqsClient = new SQSClient({ region: 'eu-west-2' });

const restartScheduleQueueUrl = `${process.env.RESTART_SCHEDULE_QUEUE_URL}`;

const sendRestartMessage = async (teamName: string, restartDateTime: string) =>
  sqsClient.send(
    new SendMessageCommand({
      QueueUrl: restartScheduleQueueUrl,
      MessageBody: JSON.stringify(
        validateRestartSchedule({
          type: 'initialise',
          restartDateTime,
          teamName,
        }),
      ),
    }),
  );

const getRestartDateTime = () => {
  const today = new Date();
  const restartDate = new Date(Date.UTC(today.getUTCFullYear(), today.getUTCMonth(), today.getUTCDate(), 12, 0, 0));
  if (today.getDay() === 6) {
    restartDate.setMinutes(30);
  }

  return restartDate.toISOString();
};

const handleRecord = ({ dynamodb: { NewImage } }) => {
  if (!NewImage) {
    return null;
  }

  console.log(JSON.stringify(NewImage, null, 2));

  const { firstTeam, secondTeam } = NewImage;
  return Promise.all([firstTeam ? 'firstTeam' : null, secondTeam ? 'secondTeam' : null].filter(Boolean).map(teamName => sendRestartMessage(teamName || '', getRestartDateTime())));
};

export const handler = async ({ Records }) => {
  await Promise.all(Records.map(handleRecord));
};
