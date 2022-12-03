import { z } from 'zod';

const BowlingFiguresSchema = z.object({
  name: z.string(),
  overs: z.string(),
  maidens: z.string(),
  runs: z.string(),
  wickets: z.string(),
  wides: z.string(),
  noBalls: z.string(),
  economyRate: z.string(),
});

const PlayerInningsSchema = z.object({
  name: z.string(),
  runs: z.string(),
  balls: z.string(),
  minutes: z.string(),
  fours: z.string(),
  sixes: z.string(),
  strikeRate: z.string(),
  howout: z.array(z.string()),
});

const InningsSchema = z.object({
  batting: z.object({
    innings: z.array(PlayerInningsSchema),
    extras: z.string(),
    total: z.string(),
  }),
  fallOfWickets: z.string(),
  bowling: z.array(BowlingFiguresSchema),
});

const ScorecardSchema = z.object({
  teamName: z.string(),
  result: z.string().nullable(),
  innings: z.array(InningsSchema),
});

export type Scorecard = z.infer<typeof ScorecardSchema>;
export type Innings = z.infer<typeof InningsSchema>;
export type PlayerInnings = z.infer<typeof PlayerInningsSchema>;
export type BowlingFigures = z.infer<typeof BowlingFiguresSchema>;

export const validateScorecard = (scorecard: unknown): Scorecard => ScorecardSchema.parse(scorecard);
