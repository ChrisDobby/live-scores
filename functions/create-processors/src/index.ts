import { EC2Client, RunInstancesCommand, RunInstancesCommandOutput } from '@aws-sdk/client-ec2';

const USER_DATA = `#!/bin/bash
yum update -y
yum install -y git
yum install -y pango.x86_64 libXcomposite.x86_64 libXcursor.x86_64 libXdamage.x86_64 libXext.x86_64 libXi.x86_64 libXtst.x86_64 cups-libs.x86_64 libXScrnSaver.x86_64 libXrandr.x86_64 GConf2.x86_64 alsa-lib.x86_64 atk.x86_64 gtk3.x86_64 ipa-gothic-fonts xorg-x11-fonts-100dpi xorg-x11-fonts-75dpi xorg-x11-utils xorg-x11-fonts-cyrillic xorg-x11-fonts-Type1 xorg-x11-fonts-misc
curl -sL https://rpm.nodesource.com/setup_16.x | sudo bash -
yum install -y nodejs
git clone https://github.com/ChrisDobby/cleckheaton-cc.git
cd cleckheaton-cc/live-scores/scorecard-processor
npm ci
`;

const client = new EC2Client({ region: 'eu-west-2' });

type ScorecardUrl = { teamName: string; scorecardUrl: string };
const getStartCommand = ({ teamName, scorecardUrl }: ScorecardUrl) => `npm start ${scorecardUrl} ${process.env.PROCESSOR_QUEUE_URL} ${teamName}`;

const createInstance = (scorecardUrls: ScorecardUrl[]) => {
  const userData = `${USER_DATA} ${scorecardUrls.map(getStartCommand).join(' & ')}`;
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
        Tags: [
          { Key: 'Owner', Value: 'cleckheaton-cc' },
          { Key: 'InProgress', Value: scorecardUrls.length.toString() },
        ],
      },
    ],
  });

  return client.send(command);
};

const getScorecardUrl = (teamName: string, field?: { S: string }) => (!field ? null : { teamName, scorecardUrl: field.S });

const handleRecord = async ({ dynamodb: { NewImage } }): Promise<RunInstancesCommandOutput | null> => {
  if (!NewImage) {
    return null;
  }

  console.log(JSON.stringify(NewImage, null, 2));
  const { firstTeam, secondTeam } = NewImage;
  return createInstance([getScorecardUrl('firstTeam', firstTeam), getScorecardUrl('secondTeam', secondTeam)].filter(Boolean) as ScorecardUrl[]);
};

export const handler = async ({ Records }) => {
  await Promise.all(Records.map(handleRecord));
};
