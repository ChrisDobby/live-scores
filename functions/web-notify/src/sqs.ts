import { SQSClient, SendMessageCommand } from '@aws-sdk/client-sqs';

const deleteSubscriptionQueueUrl = `${process.env.DELETE_SUBSCRIPTION_QUEUE_URL}`;

const sqsClient = new SQSClient({ region: 'eu-west-2' });

export const sendDeleteSubscriptionMessage = async (endpoint: string) => {
  await sqsClient.send(
    new SendMessageCommand({
      QueueUrl: deleteSubscriptionQueueUrl,
      MessageBody: JSON.stringify({ endpoint }),
    }),
  );
};
