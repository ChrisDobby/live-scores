import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import { DynamoDBDocumentClient, PutCommand } from '@aws-sdk/lib-dynamodb';

const client = new DynamoDBClient({});
const documentClient = DynamoDBDocumentClient.from(client);

const TableName = 'cleckheaton-cc-live-score-connections';

export const handler = async event => {
  const { connectionId } = event.requestContext;
  await documentClient.send(
    new PutCommand({
      TableName,
      Item: {
        connectionId,
        expiry: Math.floor(Date.now() / 1000) + 24 * 60 * 60,
      },
    }),
  );

  return { statusCode: 200 };
};
