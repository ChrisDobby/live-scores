import { DynamoDBClient, ScanCommand } from '@aws-sdk/client-dynamodb';
import { ApiGatewayManagementApiClient, PostToConnectionCommand } from '@aws-sdk/client-apigatewaymanagementapi';
import { Scorecard, validateScorecard } from '@cleckheaton-ccc-live-scores/schema';

const dynamoClient = new DynamoDBClient({ region: 'eu-west-2' });

const apiGatewayClient = new ApiGatewayManagementApiClient({ region: 'eu-west-2', endpoint: `${process.env.SOCKET_ENDPOINT}` });

const sendScorecard = (scorecard: Scorecard) => async connectionId => {
  const command = new PostToConnectionCommand({
    ConnectionId: connectionId,
    Data: Buffer.from(JSON.stringify(scorecard)),
  });

  return apiGatewayClient.send(command);
};

const sendToSockets = async (scorecardMessage: unknown) => {
  const scorecard = validateScorecard(scorecardMessage);
  console.log(scorecard);
  if (!scorecard.innings || !scorecard.innings.length) {
    return;
  }

  const command = new ScanCommand({ TableName: `${scorecard.club}-${process.env.CONNECTIONS_TABLE_SUFFIX}` });
  const scanResult = await dynamoClient.send(command);
  if (!scanResult.Items) {
    console.log('No connections found');
    return;
  }

  const send = sendScorecard(scorecard);
  return Promise.all(scanResult.Items.map(item => send(item.connectionId.S)));
};

export const handler = async ({ Records }) => {
  console.log(JSON.stringify(Records, null, 2));
  await Promise.all(Records.map(({ Sns: { Message } }) => sendToSockets(JSON.parse(Message))));
};
