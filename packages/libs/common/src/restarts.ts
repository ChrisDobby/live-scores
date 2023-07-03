import {
  CreateScheduleGroupCommand,
  ListScheduleGroupsCommand,
  SchedulerClient,
  CreateScheduleCommand,
  DeleteScheduleGroupCommand,
  ListSchedulesCommand,
  DeleteScheduleCommand,
} from '@aws-sdk/client-scheduler';

const schedulerClient = new SchedulerClient({});

const getRestartScheduleGroupName = (teamName: string) => `cleckheaton-cc-}${teamName}`;

export const addRestart = async (teamName: string, restartDateTime: string) => {
  const groupName = getRestartScheduleGroupName(teamName);
  const { ScheduleGroups } = await schedulerClient.send(new ListScheduleGroupsCommand({}));
  if (!ScheduleGroups?.find(group => group.Name === groupName)) {
    await schedulerClient.send(new CreateScheduleGroupCommand({ Name: groupName }));
  }

  await schedulerClient.send(
    new CreateScheduleCommand({
      Name: `${teamName}-restart`,
      ScheduleExpression: restartDateTime,
      GroupName: groupName,
      State: 'ENABLED',
      FlexibleTimeWindow: {
        Mode: 'OFF',
      },
      Target: {
        Arn: '',
        RoleArn: '',
      },
    }),
  );
};

export const removeRestarts = async (teamName: string) => {
  const { Schedules } = await schedulerClient.send(new ListSchedulesCommand({ GroupName: getRestartScheduleGroupName(teamName) }));
  if (!Schedules) {
    return;
  }

  await Promise.all(Schedules.map(({ Name, GroupName }) => schedulerClient.send(new DeleteScheduleCommand({ Name, GroupName }))));
};

export const removeRestartGroup = (teamName: string) => schedulerClient.send(new DeleteScheduleGroupCommand({ Name: getRestartScheduleGroupName(teamName) }));
