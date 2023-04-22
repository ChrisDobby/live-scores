import { Scorecard, Update } from '@cleckheaton-ccc-live-scores/schema';
import { getOvers } from '@cleckheaton-ccc-live-scores/common';
import { Push } from './types';

type UpdateParams = { scorecard: Scorecard; push: Push; updates: Update[] };

const oversUpdate = ({ scorecard, push, updates }: UpdateParams): UpdateParams => {
  const overs = getOvers(scorecard);
  return overs[overs.length - 1] - push.overs >= 10
    ? {
        scorecard,
        updates: [
          ...updates,
          {
            type: 'overs',
            team: scorecard.teamName,
            text: `${scorecard.innings[scorecard.innings.length - 1].batting.team} ${scorecard.innings[scorecard.innings.length - 1].batting.total}`,
          },
        ],
        push: { ...push, overs: overs[overs.length - 1] },
      }
    : { scorecard, updates, push };
};

const wicketsUpdate = ({ scorecard, updates, push }: UpdateParams): UpdateParams => ({
  scorecard,
  ...scorecard.innings[scorecard.innings.length - 1].batting.innings.reduce(
    (params, inning, index) =>
      inning.howout.filter(ho => ho.toLowerCase().trim() !== 'not out').length && params.push.wickets.includes(index)
        ? {
            updates: [
              ...params.updates,
              {
                type: 'wicket',
                team: scorecard.teamName,
                text: `${inning.name} ${inning.howout.join(' ')} ${inning.runs}`,
              },
            ],
            push: { ...params.push, wickets: [...params.push.wickets, index] },
          }
        : params,
    { updates, push },
  ),
});

const runsUpdate =
  (runs: number) =>
  ({ scorecard, updates, push }: UpdateParams): UpdateParams => ({
    scorecard,
    ...scorecard.innings[scorecard.innings.length - 1].batting.innings.reduce(
      (params, inning, index) =>
        Number(inning.runs) >= runs && !params.push.battingLandmarks.find(lm => lm.index === index && lm.runs === runs)
          ? {
              updates: [
                ...params.updates,
                {
                  type: 'landmark',
                  team: scorecard.teamName,
                  text: `${inning.name} ${inning.runs} from ${inning.balls} balls. ${inning.fours} 4s and ${inning.sixes} 6s`,
                },
              ],
              push: { ...params.push, battingLandmarks: [...params.push.battingLandmarks, { index, runs }] },
            }
          : params,
      { updates, push },
    ),
  });

const fiftyUpdate = runsUpdate(50);
const hundredUpdate = runsUpdate(100);

const wicketsTakenUpdate =
  (wickets: number) =>
  ({ scorecard, updates, push }: UpdateParams): UpdateParams => ({
    scorecard,
    ...scorecard.innings[scorecard.innings.length - 1].bowling.reduce(
      (params, bowling, index) =>
        Number(bowling.wickets) >= wickets && !params.push.bowlingLandmarks.find(lm => lm.index === index && lm.wickets === wickets)
          ? {
              updates: [
                ...params.updates,
                {
                  type: 'landmark',
                  team: scorecard.teamName,
                  text: `${bowling.name} ${bowling.wickets} - ${bowling.runs} from ${bowling.overs} overs}`,
                },
              ],
              push: { ...params.push, bowlingLandmarks: [...params.push.bowlingLandmarks, { index, wickets }] },
            }
          : params,
      { updates, push },
    ),
  });

const fiveFerUpdate = wicketsTakenUpdate(5);
const tenFerUpdate = wicketsTakenUpdate(10);

const resultUpdate = ({ scorecard, updates, push }: UpdateParams): UpdateParams => ({
  scorecard,
  updates: scorecard.result === push.result ? updates : [...updates, { type: 'result', team: scorecard.teamName, text: `${scorecard.result}` }],
  push: scorecard.result === push.result ? push : { ...push, result: scorecard.result },
});

const updatePush = (push: Push, scorecard: Scorecard) =>
  push.inningsNumber === scorecard.innings.length ? push : { inningsNumber: scorecard.innings.length, overs: 0, wickets: [] };

export const getUpdate = (scorecard: Scorecard, push: Push) =>
  [oversUpdate].reduce((params, update) => update(params), {
    scorecard,
    push: updatePush(push, scorecard),
    updates: [],
  } as UpdateParams);
