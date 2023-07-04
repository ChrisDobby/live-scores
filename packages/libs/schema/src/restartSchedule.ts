import { z } from 'zod';

const CreateScheduleSchema = z.object({
  type: z.literal('create'),
  teamName: z.string(),
  restartDateTime: z.string().datetime(),
});

const ClearSchedulesSchema = z.object({
  type: z.literal('clear'),
  teamName: z.string(),
});

const RestartSchedulesSchema = z.union([CreateScheduleSchema, ClearSchedulesSchema]);

export type CreateSchedule = z.infer<typeof CreateScheduleSchema>;
export type ClearSchedules = z.infer<typeof ClearSchedulesSchema>;

export type RestartSchedules = z.infer<typeof RestartSchedulesSchema>;

export const validateRestartSchedule = (restartSchedule: unknown): RestartSchedules => RestartSchedulesSchema.parse(restartSchedule);
