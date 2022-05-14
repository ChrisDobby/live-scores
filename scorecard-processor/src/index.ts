import puppeteer, { ElementHandle, Page } from 'puppeteer';
import { S3Client, PutObjectCommand } from '@aws-sdk/client-s3';

const sleep = (ms: number) => new Promise((resolve) => setTimeout(resolve, ms));

const findScorecardTab = async (page: Page) => {
  let scorecardTab: ElementHandle<Element> | null = null;
  while (true) {
    scorecardTab = await page.$('#nvScorecardTab-tab');
    if (scorecardTab) {
      break;
    }
    console.log('no live scorecard available, waiting to try again..');
    await sleep(300000);
  }

  return scorecardTab;
};

const processScorecardHtml = (s3Prefix: string, page: Page) => async () => {
  const content = await page.$eval('#nvScorecardTab', (el) => el.innerHTML);
  console.log(content);
  const s3 = new S3Client({ region: 'eu-west-2' });
  const command = new PutObjectCommand({
    Bucket: 'cleckheaton-cc-live-scores-html',
    Body: content,
    Key: `${s3Prefix}-${new Date().toISOString()}.html`,
  });
  console.log('sending to s3');
  await s3.send(command);
  console.log('sent');
};

(async () => {
  const teamId = process.argv[2];
  if (!teamId) {
    throw new Error('No team specified');
  }

  const scorecardUrl = process.argv[3];
  if (!scorecardUrl) {
    throw new Error('No scorecard url specified');
  }

  const browser = await puppeteer.launch({
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox'],
  });
  const page = await browser.newPage();
  await page.goto(scorecardUrl);

  const [acceptButton] = await page.$x('//button[text()="ACCEPT"]');
  await acceptButton.click();

  await findScorecardTab(page);
  page.$eval('#nvScorecardTab-tab', (el: any) => el.click());

  setInterval(processScorecardHtml(teamId, page), 300000);
})();
