import { DynamoDB } from 'aws-sdk';

const dynamoClient = new DynamoDB({ region: 'eu-west-2' });
const TableName = 'cleckheaton-cc-live-score-connections';

export const handler = async event => {
  const { connectionId } = event.requestContext;
  await dynamoClient
    .putItem({
      TableName,
      Item: {
        connectionId: { S: connectionId },
        expiry: { N: `${Math.floor(Date.now() / 1000) + 24 * 60 * 60}` },
      },
    })
    .promise();

  return { statusCode: 200 };
};
