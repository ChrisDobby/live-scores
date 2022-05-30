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

export const put = (
  date: string,
  { firstTeam, secondTeam }: ScorecardUrls
): Promise<DynamoDB.PutItemOutput> => {
  const dynamoItem: { [key: string]: DynamoDB.AttributeValue } = {
    date: { S: date },
    expiry: { N: `${Math.floor(Date.now() / 1000) + 24 * 60 * 60}` },
  };
  if (firstTeam) {
    dynamoItem.firstTeam = { S: firstTeam };
  }

  if (secondTeam) {
    dynamoItem.secondTeam = { S: secondTeam };
  }

  return dynamoClient
    .putItem({
      TableName,
      Item: dynamoItem,
    })
    .promise();
};
