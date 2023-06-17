import { S3Client, PutObjectCommand } from '@aws-sdk/client-s3';
import { validateScorecard } from '@cleckheaton-ccc-live-scores/schema';
import { getScorecardKey } from '@cleckheaton-ccc-live-scores/common';

const s3Client = new S3Client({});

const { SCORECARD_BUCKET_NAME: bucketName } = process.env;

const putToS3 = (scorecardMessage: unknown) => {
  const scorecard = validateScorecard(scorecardMessage);
  console.log(scorecard);
  if (!scorecard.innings || !scorecard.innings.length) {
    return;
  }

  const key = getScorecardKey(scorecard);
  console.log(`writing to ${key}`);

  const command = new PutObjectCommand({
    Bucket: bucketName,
    Key: key,
    Body: JSON.stringify(scorecard.innings),
    ACL: 'public-read',
  });

  return s3Client.send(command);
};

export const handler = async ({ Records }) => {
  console.log(JSON.stringify(Records, null, 2));
  await Promise.all(Records.map(({ Sns: { Message } }) => putToS3(JSON.parse(Message))));
};
