import chromium from 'chrome-aws-lambda';
import { ElementHandle, Page } from 'puppeteer-core';
import { get, put } from './store';

const BASE_URL = 'https://bradfordcl.play-cricket.com';

const getScorecardUrlForRow = async (row?: ElementHandle<Element>) => {
  if (!row) {
    return null;
  }

  const onclick = await row.getProperty('onclick');
  if (!onclick) {
    return null;
  }

  const func = onclick._remoteObject.description;
  const relativeUrl = func?.substring(
    func.indexOf("window.open('/website") + 13,
    func.indexOf("',")
  );

  return relativeUrl ? `${BASE_URL}${relativeUrl}` : null;
};

const getTeamRow = async (row: ElementHandle<Element>) => {
  const anchor = await row.$('a');
  const team = await anchor?.getProperty('textContent');
  return { row, team: await team?.jsonValue() };
};

const getCleckheatonScorecardUrls = async (page: Page) => {
  const rows = await page.$$('tr');
  const teamRows = await Promise.all(rows.map(getTeamRow));
  const firstTeamRow = teamRows.find(
    ({ team }) => team === 'Cleckheaton CC - 1st XI'
  )?.row;
  const secondTeamRow = teamRows.find(
    ({ team }) => team === 'Cleckheaton CC - 2nd XI'
  )?.row;

  return {
    firstTeam: await getScorecardUrlForRow(firstTeamRow),
    secondTeam: await getScorecardUrlForRow(secondTeamRow),
  };
};

export const handler = async () => {
  const date = new Date().toDateString();
  const existingUrls = await get(date);
  if (existingUrls) {
    console.log('existingUrls', existingUrls);
    return;
  }

  console.log('starting puppeteer');
  const browser = await chromium.puppeteer.launch({
    args: chromium.args,
    defaultViewport: chromium.defaultViewport,
    executablePath: await chromium.executablePath,
    headless: chromium.headless,
  });
  try {
    const page = await browser.newPage();
    await page.goto(
      'https://bradfordcl.play-cricket.com/website/web_pages/315262'
    );

    const [acceptButton] = await page.$x('//button[text()="ACCEPT"]');
    await acceptButton.click();

    const urls = await getCleckheatonScorecardUrls(page);
    if (urls) {
      await put(date, urls);
    }
  } finally {
    browser.close();
  }
};
