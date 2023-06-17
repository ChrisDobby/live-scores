import { z } from 'zod';

const GameOverSchema = z.object({
  url: z.string(),
  teamName: z.string(),
  result: z.string(),
});

export type GameOver = z.infer<typeof GameOverSchema>;

export const validateGameOver = (gameOver: unknown): GameOver => GameOverSchema.parse(gameOver);
