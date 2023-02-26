import { SNSClient, PublishCommand } from '@aws-sdk/client-sns';
import { Update } from '@cleckheaton-ccc-live-scores/schema';

const snsClient = new SNSClient({});

const { PUSH_TOPIC_ARN: pushTopicArn } = process.env;

export const publishToSns = async (update: Update) => {
  console.log(`publising to ${pushTopicArn}`);
  const command = new PublishCommand({
    TopicArn: pushTopicArn,
    Message: JSON.stringify(update),
  });

  await snsClient.send(command);
};
