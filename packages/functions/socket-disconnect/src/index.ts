import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import { DynamoDBDocumentClient, DeleteCommand } from '@aws-sdk/lib-dynamodb';

const client = new DynamoDBClient({});
const documentClient = DynamoDBDocumentClient.from(client);

const TableName = `${process.env.CONNECTIONS_TABLE}`;

export const handler = async event => {
  const { connectionId } = event.requestContext;
  await documentClient.send(new DeleteCommand({ TableName, Key: { connectionId } }));
  return { statusCode: 200 };
};
