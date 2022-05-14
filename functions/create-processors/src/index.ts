import {
  EC2Client,
  RunInstancesCommand,
  RunInstancesCommandOutput,
} from '@aws-sdk/client-ec2';

const USER_DATA = `#!/bin/bash
yum update -y
yum install -y git
yum install -y pango.x86_64 libXcomposite.x86_64 libXcursor.x86_64 libXdamage.x86_64 libXext.x86_64 libXi.x86_64 libXtst.x86_64 cups-libs.x86_64 libXScrnSaver.x86_64 libXrandr.x86_64 GConf2.x86_64 alsa-lib.x86_64 atk.x86_64 gtk3.x86_64 ipa-gothic-fonts xorg-x11-fonts-100dpi xorg-x11-fonts-75dpi xorg-x11-utils xorg-x11-fonts-cyrillic xorg-x11-fonts-Type1 xorg-x11-fonts-misc
curl -sL https://rpm.nodesource.com/setup_16.x | sudo bash -
yum install -y nodejs
git clone https://github.com/ChrisDobby/cleckheaton-cc.git
cd cleckheaton-cc
git checkout live-scores
cd live-scores/scorecard-processor
npm i
npm run build
npm run start`;

const client = new EC2Client({ region: 'eu-west-2' });

const getQueueUrl = (teamId: string) => {
  switch (teamId) {
    case '1':
      return process.env.FIRST_TEAM_PROCESSOR_QUEUE_URL as string;
    case '2':
      return process.env.SECOND_TEAM_PROCESSOR_QUEUE_URL as string;
    default:
      return '';
  }
};

const createInstance = (teamId: string, scorecardUrl: string) => {
  const userData = `${USER_DATA} ${scorecardUrl} ${getQueueUrl(teamId)}`;
  const command = new RunInstancesCommand({
    ImageId: 'ami-0d729d2846a86a9e7',
    InstanceType: 't2.micro',
    MaxCount: 1,
    MinCount: 1,
    KeyName: 'test-processor',
    SecurityGroupIds: [process.env.PROCESSOR_SG_ID as string],
    IamInstanceProfile: { Arn: process.env.PROCESSOR_PROFILE_ARN },
    UserData: Buffer.from(userData).toString('base64'),
    TagSpecifications: [
      {
        ResourceType: 'instance',
        Tags: [{ Key: 'Owner', Value: 'cleckheaton-cc' }],
      },
    ],
  });

  return client.send(command);
};

const getCreator = (teamId: string, field?: { S: string }) => {
  if (!field) {
    return null;
  }

  return createInstance(teamId, field.S);
};

const handleRecord = async ({
  dynamodb: { NewImage },
}): Promise<(RunInstancesCommandOutput | null)[]> => {
  if (!NewImage) {
    return [];
  }

  console.log(JSON.stringify(NewImage, null, 2));
  const { firstTeam, secondTeam } = NewImage;
  const creators = [
    getCreator('1', firstTeam),
    getCreator('2', secondTeam),
  ].filter(Boolean);

  return Promise.all(creators);
};

export const handler = async ({ Records }) => {
  await Promise.all(Records.map(handleRecord));
};
