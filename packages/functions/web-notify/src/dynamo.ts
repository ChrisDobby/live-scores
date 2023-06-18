import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import { DynamoDBDocumentClient, ScanCommand } from '@aws-sdk/lib-dynamodb';
import { PushSubscription } from 'web-push';

const client = new DynamoDBClient({});
const documentClient = DynamoDBDocumentClient.from(client);

export const getSubscriptions = async (club: string) => {
  const { Items } = await documentClient.send(new ScanCommand({ TableName: `${club}-${process.env.SUBSCRIPTIONS_TABLE_SUFFIX}` }));
  return (Items || []) as PushSubscription[];
};
