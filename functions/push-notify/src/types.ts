export type Push = {
  inningsNumber: number;
  overs: number;
  wickets: number[];
  battingLandmarks: { index: number; runs: number }[];
  bowlingLandmarks: { index: number; wickets: number }[];
};
