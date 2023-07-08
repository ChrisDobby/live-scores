import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import { DynamoDBDocumentClient, PutCommand } from '@aws-sdk/lib-dynamodb';
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

export const handler = async ({ body, routeKey, pathParameters }) => {
  console.log(JSON.stringify(routeKey, null, 2));
  console.log(JSON.stringify(pathParameters, null, 2));
  console.log(JSON.stringify(body, null, 2));

  switch (routeKey) {
    case 'POST /':
      await subscribe(validateSubscription(JSON.parse(body)));
      break;
    case 'DELETE /{endpoint}':
      await unsubscribe(pathParameters.endpoint);
      break;
    case 'PUT /':
      await update(validateSubscription(JSON.parse(body)));
      break;
  }

  return { statusCode: 200 };
};
