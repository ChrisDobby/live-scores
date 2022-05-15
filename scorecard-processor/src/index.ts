import puppeteer, { ElementHandle, Page } from 'puppeteer';
import { SQSClient, SendMessageCommand } from '@aws-sdk/client-sqs';

let page: Page | null = null;

const sqsClient = new SQSClient({ region: 'eu-west-2' });
const sleep = (ms: number) => new Promise((resolve) => setTimeout(resolve, ms));

const findScorecardTab = async () => {
  let scorecardTab: ElementHandle<Element> | null | undefined = null;
  while (true) {
    scorecardTab = await page?.$('#nvScorecardTab-tab');
    if (scorecardTab) {
      break;
    }
    console.log('no live scorecard available, waiting to try again..');
    await sleep(300000);
  }

  return scorecardTab;
};

const processScorecardHtml = (queueUrl: string) => async () => {
  const content = await page?.$eval('#nvScorecardTab', (el) => el.innerHTML);
  console.log(content);
  const command = new SendMessageCommand({
    QueueUrl: queueUrl,
    MessageBody: content,
  });
  console.log('sending to sqs');
  await sqsClient.send(command);
  console.log('sent');
};

(async () => {
  const scorecardUrl = process.argv[2];
  if (!scorecardUrl) {
    throw new Error('No scorecard url specified');
  }

  const queueUrl = process.argv[3];
  if (!queueUrl) {
    throw new Error('No queue url specified');
  }

  console.log(`processing ${scorecardUrl} and sending to ${queueUrl}`);
  const browser = await puppeteer.launch({
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox'],
  });
  page = await browser.newPage();
  await page.goto(scorecardUrl);

  const [acceptButton] = await page.$x('//button[text()="ACCEPT"]');
  await acceptButton.click();

  await findScorecardTab();
  page.$eval('#nvScorecardTab-tab', (el: any) => el.click());

  setInterval(processScorecardHtml(queueUrl), 300000);
})();
