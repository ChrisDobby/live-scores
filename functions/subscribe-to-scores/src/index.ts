import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import { DynamoDBDocumentClient, PutCommand, DeleteCommand } from '@aws-sdk/lib-dynamodb';
import { validateWebNotification, validateSubscription, Subscription } from '@cleckheaton-ccc-live-scores/schema';
import { addToDeleteSubscriptionQueue, addToWebNotifyQueue } from './sqs';

const client = new DynamoDBClient({});
const documentClient = DynamoDBDocumentClient.from(client);

const TableName = 'cleckheaton-cc-live-score-subscriptions';

const update = async (subscription: Subscription) => {
  await documentClient.send(new PutCommand({ TableName, Item: subscription }));
};

const subscribe = async (subscription: Subscription) => {
  await update(subscription);
  await addToWebNotifyQueue(validateWebNotification({ subscription, title: 'Cleckheaton CC', body: 'You are now subscribed to live score updates of all 1st and 2nd Team games' }));
};

const unsubscribe = async (endpoint: string) => {
  await addToDeleteSubscriptionQueue(endpoint);
};

export const handler = async ({ body, path }) => {
  console.log(JSON.stringify(body, null, 2));
  const validateResult = validateSubscription(JSON.parse(body));
  if (!validateResult.success) {
    return { statusCode: 400, body: JSON.stringify(validateResult.error) };
  }

  const { data: subscription } = validateResult;
  const route = path.split('/').slice(-1)[0];
  switch (route) {
    case 'subscribe':
      await subscribe(subscription);
      break;
    case 'unsubscribe':
      unsubscribe(subscription.endpoint);
      break;
    case 'update':
      update(subscription);
      break;
  }

  return { statusCode: 200 };
};
