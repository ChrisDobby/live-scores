import { SNSClient, PublishCommand } from '@aws-sdk/client-sns';
import { Scorecard } from '@cleckheaton-ccc-live-scores/schema';
import { getScorecard } from './scorecard';

const snsClient = new SNSClient({});

const { UPDATE_SNS_TOPIC_ARN: snsTopicArn } = process.env;

const publishToSns = (scorecard: Scorecard) => {
  console.log(`publising to ${snsTopicArn}`);
  const command = new PublishCommand({
    TopicArn: snsTopicArn,
    Message: JSON.stringify(scorecard),
  });

  return snsClient.send(command);
};

const processRecord = ({ body, eventSourceARN }) => {
  const { scorecardHtml, headerHtml, scorecardUrl } = JSON.parse(body);
  const scorecard = getScorecard(scorecardUrl, scorecardHtml, headerHtml, eventSourceARN);
  console.log(scorecard);
  return publishToSns(scorecard);
};

export const handler = async ({ Records }) => {
  console.log(Records);
  const result = await Promise.all(Records.map(processRecord));
  console.log(result);
};
