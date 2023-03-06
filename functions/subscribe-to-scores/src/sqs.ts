import { WebNotification } from '@cleckheaton-ccc-live-scores/schema';
import { SQSClient, SendMessageCommand } from '@aws-sdk/client-sqs';

const sqsClient = new SQSClient({ region: 'eu-west-2' });

const webNotifyQueueUrl = `${process.env.WEB_NOTIFY_QUEUE_URL}`;

export const addToWebNotifyQueue = async (webNotification: WebNotification) =>
  sqsClient.send(
    new SendMessageCommand({
      QueueUrl: webNotifyQueueUrl,
      MessageBody: JSON.stringify(webNotification),
    }),
  );
