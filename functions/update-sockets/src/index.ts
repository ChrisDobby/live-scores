import { DynamoDBClient, ScanCommand } from '@aws-sdk/client-dynamodb';
import { ApiGatewayManagementApiClient, PostToConnectionCommand } from '@aws-sdk/client-apigatewaymanagementapi';

const dynamoClient = new DynamoDBClient({ region: 'eu-west-2' });
const TableName = 'cleckheaton-cc-live-score-connections';

const apiGatewayClient = new ApiGatewayManagementApiClient({ region: 'eu-west-2', endpoint: `${process.env.SOCKET_ENDPOINT}/$connections` });

const sendScorecard = scorecard => async connectionId => {
  const command = new PostToConnectionCommand({
    ConnectionId: connectionId,
    Data: scorecard,
  });

  return apiGatewayClient.send(command);
};

const sendToSockets = async scorecard => {
  console.log(scorecard);
  if (!scorecard.innings || !scorecard.innings.length) {
    return;
  }

  const command = new ScanCommand({ TableName });
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
