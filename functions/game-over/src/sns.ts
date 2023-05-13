import { SNSClient, PublishCommand } from '@aws-sdk/client-sns';
import { Scorecard } from '@cleckheaton-ccc-live-scores/schema';

const snsClient = new SNSClient({});

const { GAME_OVER_TOPIC_ARN: gameOverTopicArn } = process.env;

export const publishToSns = async ({ result, teamName, url }: Scorecard) =>
  snsClient.send(
    new PublishCommand({
      TopicArn: gameOverTopicArn,
      Message: JSON.stringify({ result, teamName, url }),
    }),
  );
