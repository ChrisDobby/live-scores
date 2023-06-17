import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import { DynamoDBDocumentClient, GetCommand, PutCommand, PutCommandOutput } from '@aws-sdk/lib-dynamodb';

const TableName = 'cleckheaton-cc-live-score-urls';

type ScorecardUrls = {
  firstTeam: string | null;
  secondTeam: string | null;
};

const client = new DynamoDBClient({});

const documentClient = DynamoDBDocumentClient.from(client);

export const get = async (date: string): Promise<ScorecardUrls | null> => {
  const { Item } = await documentClient.send(
    new GetCommand({
      TableName,
      Key: { date },
    }),
  );

  return Item
    ? {
        firstTeam: Item.firstTeam?.S ? Item.firstTeam.S : null,
        secondTeam: Item.secondTeam?.S ? Item.secondTeam.S : null,
      }
    : null;
};

export const put = (date: string, { firstTeam, secondTeam }: ScorecardUrls): Promise<PutCommandOutput> => {
  const dynamoItem: Record<string, unknown> = {
    date,
    expiry: Math.floor(Date.now() / 1000) + 24 * 60 * 60,
  };

  if (firstTeam) {
    dynamoItem.firstTeam = firstTeam;
  }

  if (secondTeam) {
    dynamoItem.secondTeam = secondTeam;
  }

  return documentClient.send(new PutCommand({ TableName, Item: dynamoItem }));
};
