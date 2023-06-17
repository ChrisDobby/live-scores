import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import { DynamoDBDocumentClient, DeleteCommand } from '@aws-sdk/lib-dynamodb';

const client = new DynamoDBClient({});
const documentClient = DynamoDBDocumentClient.from(client);

const TableName = 'cleckheaton-cc-live-score-subscriptions';

const unsubscribe = async ({ endpoint }: { endpoint: string }) => {
  await documentClient.send(new DeleteCommand({ TableName, Key: { endpoint } }));
};

export const handler = async ({ Records }) => {
  await Promise.all(Records.map(({ body }) => unsubscribe(JSON.parse(body))));
};
