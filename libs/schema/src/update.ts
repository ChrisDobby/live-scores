import { z } from 'zod';

const UpdateSchema = z.object({
  type: z.union([z.literal('overs'), z.literal('wicket'), z.literal('landmark'), z.literal('result')]),
  team: z.string(),
  text: z.string(),
});

export type Update = z.infer<typeof UpdateSchema>;

export const validateUpdate = (update: unknown): Update => UpdateSchema.parse(update);
