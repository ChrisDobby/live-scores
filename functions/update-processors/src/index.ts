import { EC2Client, DescribeInstancesCommand, TerminateInstancesCommand, Instance, CreateTagsCommand } from '@aws-sdk/client-ec2';
import { validateScorecard } from '@cleckheaton-ccc-live-scores/schema';

const ec2Client = new EC2Client([]);

const terminateInstance = async (instanceId: string) =>
  ec2Client.send(
    new TerminateInstancesCommand({
      InstanceIds: [instanceId],
    }),
  );

const setInProgressCount = async (instanceId: string, inProgressCount: number) =>
  ec2Client.send(
    new CreateTagsCommand({
      Resources: [instanceId],
      Tags: [{ Key: 'InProgress', Value: `${inProgressCount}` }],
    }),
  );

const updateInstance = async ({ InstanceId, Tags }: Instance) => {
  if (!InstanceId) {
    return;
  }

  const inProgressTag = Number(Tags?.find(({ Key }) => Key === 'InProgress')?.Value);
  if (inProgressTag && inProgressTag > 1) {
    await setInProgressCount(InstanceId, inProgressTag - 1);
  } else {
    await terminateInstance(InstanceId);
  }
};

const updateProcessor = async (scorecardMessage: unknown) => {
  const scorecard = validateScorecard(scorecardMessage);
  if (!scorecard.result || !scorecard.teamName) {
    return;
  }

  const command = new DescribeInstancesCommand({
    Filters: [{ Name: 'tag:Owner', Values: ['cleckheaton-cc'] }],
  });

  const instances = await ec2Client.send(command);
  console.log(instances);

  if (!instances.Reservations?.length) {
    return;
  }

  await Promise.all(instances.Reservations.flatMap(({ Instances }) => Instances?.map(updateInstance)));
};

export const handler = async ({ Records }) => {
  console.log(JSON.stringify(Records, null, 2));
  await Promise.all(Records.map(({ Sns: { Message } }) => updateProcessor(JSON.parse(Message))));
};
