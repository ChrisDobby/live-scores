const handleGameOver = scorecard => {
  console.log(scorecard);
  if (scorecard.result) {
    console.log(`GAME OVER ${scorecard.result}`);
  }
};

export const handler = async ({ Records }) => {
  console.log(JSON.stringify(Records, null, 2));
  await Promise.all(Records.map(({ Sns: { Message } }) => handleGameOver(JSON.parse(Message))));
};
