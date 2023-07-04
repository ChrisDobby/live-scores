import {
  CreateScheduleGroupCommand,
  ListScheduleGroupsCommand,
  SchedulerClient,
  CreateScheduleCommand,
  DeleteScheduleGroupCommand,
  ListSchedulesCommand,
  DeleteScheduleCommand,
} from '@aws-sdk/client-scheduler';
import { RestartSchedules, CreateSchedule } from '@cleckheaton-ccc-live-scores/schema';

const schedulerClient = new SchedulerClient({});

const restartProcessorArn = `${process.env.RESTART_PROCESSOR_ARN}`;
const schedulerRoleArn = `${process.env.SCHEDULER_ROLE_ARN}`;

const getRestartScheduleGroupName = (teamName: string) => `cleckheaton-cc-}${teamName}`;

const addRestart = async (teamName: string, restartDateTime: string) => {
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
        Arn: restartProcessorArn,
        RoleArn: schedulerRoleArn,
        Input: JSON.stringify({ date: new Date().toDateString() }),
      },
    }),
  );
};

const removeRestarts = async (teamName: string) => {
  const { Schedules } = await schedulerClient.send(new ListSchedulesCommand({ GroupName: getRestartScheduleGroupName(teamName) }));
  if (!Schedules) {
    return;
  }

  await Promise.all(Schedules.map(({ Name, GroupName }) => schedulerClient.send(new DeleteScheduleCommand({ Name, GroupName }))));
};

const removeRestartGroup = (teamName: string) => schedulerClient.send(new DeleteScheduleGroupCommand({ Name: getRestartScheduleGroupName(teamName) }));

const createRestart = async (initialise: CreateSchedule) => {
  await removeRestarts(initialise.teamName);
  await addRestart(initialise.teamName, initialise.restartDateTime);
};

export const handleRestart = (restartSchedule: RestartSchedules) => {
  switch (restartSchedule.type) {
    case 'create':
      return createRestart(restartSchedule);
    case 'clear':
      return removeRestartGroup(restartSchedule.teamName);
  }
};
