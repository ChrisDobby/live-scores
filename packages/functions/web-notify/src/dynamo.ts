import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import { DynamoDBDocumentClient, ScanCommand } from '@aws-sdk/lib-dynamodb';
import { PushSubscription } from 'web-push';

const client = new DynamoDBClient({});
const documentClient = DynamoDBDocumentClient.from(client);

const TableName = 'cleckheaton-cc-live-score-subscriptions';

export const getSubscriptions = async () => {
  const { Items } = await documentClient.send(new ScanCommand({ TableName }));
  return (Items || []) as PushSubscription[];
};
