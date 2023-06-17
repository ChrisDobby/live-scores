import { S3Client, GetObjectCommand, ListObjectsCommand, PutObjectCommand } from '@aws-sdk/client-s3';
import { getScorecardKey } from '@cleckheaton-ccc-live-scores/common';
import { Scorecard } from '@cleckheaton-ccc-live-scores/schema';
import { Push } from './types';

const s3Client = new S3Client({});

const { PUSH_NOTIFY_BUCKET_NAME: bucketName } = process.env;

const emptyPush = {
  inningsNumber: 1,
  overs: 0,
  wickets: [],
  battingLandmarks: [],
  bowlingLandmarks: [],
  result: null,
};

export const getLastPush = async (scorecard: Scorecard): Promise<Push> => {
  const key = getScorecardKey(scorecard);
  const { Contents } = await s3Client.send(new ListObjectsCommand({ Bucket: bucketName }));
  if (!Contents || !Contents.find(({ Key }) => Key === key)) {
    return emptyPush;
  }

  const { Body } = await s3Client.send(
    new GetObjectCommand({
      Bucket: bucketName,
      Key: key,
    }),
  );

  return Body ? ((await new Response(Body as ReadableStream, {}).json()) as Push) : emptyPush;
};

export const updateLastPush = async (scorecard: Scorecard, push: Push) => {
  const key = getScorecardKey(scorecard);
  await s3Client.send(
    new PutObjectCommand({
      Bucket: bucketName,
      Key: key,
      Body: JSON.stringify(push),
    }),
  );
};
