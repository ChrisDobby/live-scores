import puppeteer, { ElementHandle, Page } from 'puppeteer';
import { S3Client, PutObjectCommand } from '@aws-sdk/client-s3';
import { get } from './store';

const TEAM_CONFIG = {
  1: { fieldName: 'firstTeam', s3KeyPrefix: '1st-team' },
  2: { fieldName: 'secondTeam', s3KeyPrefix: '2st-team' },
};

const sleep = (ms: number) => new Promise((resolve) => setTimeout(resolve, ms));

const findScorecardTab = async (page: Page) => {
  let scorecardTab: ElementHandle<Element> | null = null;
  while (true) {
    scorecardTab = await page.$('#nvScorecardTab-tab');
    if (scorecardTab) {
      break;
    }

    await sleep(300000);
  }

  return scorecardTab;
};

const processScorecardHtml = (s3Prefix: string, page: Page) => async () => {
  const content = await page.$eval('#nvScorecardTab', (el) => el.innerHTML);
  console.log(content);
  const s3 = new S3Client({ region: 'us-east-1' });
  const command = new PutObjectCommand({
    Bucket: 'cleckheaton-cc-live-scores-test-1',
    Body: content,
    Key: `${s3Prefix}-${new Date().toISOString()}.html`,
  });
  console.log('sending to s3');
  await s3.send(command);
  console.log('sent');
};

(async () => {
  const teamArg = process.argv[2];
  if (!teamArg) {
    throw new Error('No team specified');
  }

  const config = TEAM_CONFIG[teamArg];
  if (!config) {
    throw new Error(`Invalid team: ${teamArg}`);
  }

  const urls = await get(new Date().toDateString());
  if (!urls || !urls[config.fieldName]) {
    throw new Error(`No scorecard url for ${config.fieldName}`);
  }

  const browser = await puppeteer.launch({ headless: true });
  const page = await browser.newPage();
  await page.goto(urls[config.fieldName]);

  const [acceptButton] = await page.$x('//button[text()="ACCEPT"]');
  await acceptButton.click();

  await findScorecardTab(page);
  page.$eval('#nvScorecardTab-tab', (el: any) => el.click());

  setInterval(processScorecardHtml(config.s3KeyPrefix, page), 300000);
})();
