import { EC2Client, DescribeInstancesCommand, TerminateInstancesCommand } from '@aws-sdk/client-ec2';

const ec2Client = new EC2Client([]);

const teamTags = {
  firstTeam: '1',
  secondTeam: '2',
};

const updateProcessor = async scorecard => {
  if (!scorecard.result || !scorecard.teamName) {
    return;
  }

  const command = new DescribeInstancesCommand({
    Filters: [
      { Name: 'tag:Owner', Values: ['cleckheaton-cc'] },
      { Name: 'tag:Team', Values: [teamTags[scorecard.teamName]] },
    ],
  });

  const instances = await ec2Client.send(command);
  console.log(instances);

  if (!instances.Reservations?.length) {
    return;
  }

  const instanceIds = instances.Reservations.flatMap(({ Instances }) => Instances?.map(({ InstanceId }) => InstanceId)).filter(Boolean) as string[];
  const terminateCommand = new TerminateInstancesCommand({
    InstanceIds: instanceIds,
  });

  await ec2Client.send(terminateCommand);
};

export const handler = async ({ Records }) => {
  console.log(JSON.stringify(Records, null, 2));
  await Promise.all(Records.map(({ Sns: { Message } }) => updateProcessor(JSON.parse(Message))));
};
