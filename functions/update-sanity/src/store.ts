import { DynamoDB } from 'aws-sdk';

const TableName = 'cleckheaton-cc-live-score-urls';

type ScorecardUrls = {
  firstTeam: string | null;
  secondTeam: string | null;
};

const dynamoClient = new DynamoDB({ region: 'eu-west-2' });
export const get = async (date: string): Promise<ScorecardUrls | null> => {
  const { Item } = await dynamoClient
    .getItem({
      TableName,
      Key: { date: { S: date } },
    })
    .promise();

  return Item
    ? {
        firstTeam: Item.firstTeam?.S ? Item.firstTeam.S : null,
        secondTeam: Item.secondTeam?.S ? Item.secondTeam.S : null,
      }
    : null;
};
