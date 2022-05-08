import { DynamoDBClient, GetItemCommand } from '@aws-sdk/client-dynamodb';

const TableName = 'cleckheaton-cc-live-score-urls';

type ScorecardUrls = {
  firstTeam: string | null;
  secondTeam: string | null;
};

const dynamoClient = new DynamoDBClient({ region: 'eu-west-2' });
export const get = async (date: string): Promise<ScorecardUrls | null> => {
  const getCommand = new GetItemCommand({
    TableName,
    Key: { date: { S: date } },
  });
  const { Item } = await dynamoClient.send(getCommand);
  return Item
    ? {
        firstTeam: Item.firstTeam?.S ? Item.firstTeam.S : null,
        secondTeam: Item.secondTeam?.S ? Item.secondTeam.S : null,
      }
    : null;
};
