import { DynamoDB } from 'aws-sdk';

const dynamoClient = new DynamoDB({ region: 'eu-west-2' });
const TableName = 'cleckheaton-cc-live-score-connections';

export const handler = async event => {
  const { connectionId } = event.requestContext;
  await dynamoClient
    .deleteItem({
      TableName,
      Key: { connectionId: { S: connectionId } },
    })
    .promise();

  return { statusCode: 200 };
};
