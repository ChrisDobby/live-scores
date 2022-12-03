import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import { DynamoDBDocumentClient, GetCommand } from '@aws-sdk/lib-dynamodb';

const client = new DynamoDBClient({});
const documentClient = DynamoDBDocumentClient.from(client);

const TableName = 'cleckheaton-cc-live-score-urls';

type ScorecardUrls = {
  firstTeam: string | null;
  secondTeam: string | null;
};

export const get = async (date: string): Promise<ScorecardUrls | null> => {
  const { Item } = await documentClient.send(
    new GetCommand({
      TableName,
      Key: { date },
    }),
  );

  return Item
    ? {
        firstTeam: Item.firstTeam || null,
        secondTeam: Item.secondTeam || null,
      }
    : null;
};
