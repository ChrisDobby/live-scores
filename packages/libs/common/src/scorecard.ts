import { Scorecard } from '@cleckheaton-ccc-live-scores/schema';

const keyName = {
  firstTeam: 'first-team.json',
  secondTeam: 'second-team.json',
};

export const getScorecardKey = (scorecard: Scorecard) => {
  const keySuffix = keyName[scorecard.teamName];
  if (!keySuffix) {
    throw new Error(`Unexpected teamName: ${scorecard.teamName}`);
  }

  const date = new Date();
  date.setHours(0, 0, 0, 0);
  return `${date.getTime()}-${keySuffix}`;
};

const extractOvers = (total: string) => {
  const openBracket = total.indexOf('(');
  if (openBracket === -1) {
    return 0;
  }

  const parts = total.substring(openBracket + 1).split(' ');
  const oversLabel = parts.indexOf('Overs,');
  const oversText = parts[oversLabel - 1];
  return Number(oversText);
};

export const getOvers = ({ innings }: Scorecard) => innings.map(({ batting: { total } }) => extractOvers(total));
