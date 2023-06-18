import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import { DynamoDBDocumentClient, DeleteCommand } from '@aws-sdk/lib-dynamodb';

const client = new DynamoDBClient({});
const documentClient = DynamoDBDocumentClient.from(client);

const unsubscribe = async ({ endpoint, club }: { endpoint: string; club: string }) => {
  await documentClient.send(new DeleteCommand({ TableName: `${club}-${process.env.SUBSCRIPTIONS_TABLE_SUFFIX}`, Key: { endpoint } }));
};

export const handler = async ({ Records }) => {
  await Promise.all(Records.map(({ body }) => unsubscribe(JSON.parse(body))));
};
