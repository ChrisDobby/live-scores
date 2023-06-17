import {
  EC2Client,
  DescribeInstancesCommand,
  TerminateInstancesCommand,
} from '@aws-sdk/client-ec2';

const ec2Client = new EC2Client([]);

export const handler = async () => {
  const command = new DescribeInstancesCommand({
    Filters: [{ Name: 'tag:Owner', Values: ['cleckheaton-cc'] }],
  });

  const instances = await ec2Client.send(command);
  console.log(instances);

  if (!instances.Reservations?.length) {
    return;
  }

  const instanceIds = instances.Reservations.flatMap(({ Instances }) =>
    Instances?.map(({ InstanceId }) => InstanceId)
  ).filter(Boolean) as string[];
  const terminateCommand = new TerminateInstancesCommand({
    InstanceIds: instanceIds,
  });

  await ec2Client.send(terminateCommand);
};
