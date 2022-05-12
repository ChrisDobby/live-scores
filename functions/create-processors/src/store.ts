import {
  DynamoDBClient,
  PutItemCommand,
  AttributeValue,
  PutItemCommandOutput,
} from '@aws-sdk/client-dynamodb';

const TableName = 'cleckheaton-cc-running-processors';

const dynamoClient = new DynamoDBClient({ region: 'eu-west-2' });
export const put = (date: string, instanceIds: string[]) => {
  if (!instanceIds.length) {
    return;
  }

  const dynamoItem: { [key: string]: AttributeValue } = {
    date: { S: date },
    expiry: { N: `${Math.floor(Date.now() / 1000) + 24 * 60 * 60}` },
    instanceIds: { L: instanceIds.map((instanceId) => ({ S: instanceId })) },
  };

  const putCommand = new PutItemCommand({
    TableName,
    Item: dynamoItem,
  });

  return dynamoClient.send(putCommand);
};
