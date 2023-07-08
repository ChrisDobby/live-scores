import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import { DynamoDBDocumentClient, PutCommand } from '@aws-sdk/lib-dynamodb';
import { validateWebNotification, validateSubscription, Subscription } from '@cleckheaton-ccc-live-scores/schema';
import { addToDeleteSubscriptionQueue, addToWebNotifyQueue } from './sqs';

const client = new DynamoDBClient({});
const documentClient = DynamoDBDocumentClient.from(client);

const TableName = `${process.env.SUBSCRIPTIONS_TABLE}`;

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

export const handler = async ({ body, httpMethod, pathParameters, ...args }) => {
  console.log(httpMethod);
  console.log(JSON.stringify(body, null, 2));
  console.log(args);

  const validateResult = validateSubscription(JSON.parse(body));
  if (!validateResult.success) {
    return { statusCode: 400, body: JSON.stringify(validateResult.error) };
  }

  const { data: subscription } = validateResult;
  switch (httpMethod) {
    case 'POST':
      await subscribe(subscription);
      break;
    case 'DELETE':
      await unsubscribe(subscription.endpoint);
      break;
    case 'PUT':
      await update(subscription);
      break;
  }

  return { statusCode: 200 };
};
