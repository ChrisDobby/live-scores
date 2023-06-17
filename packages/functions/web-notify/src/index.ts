import { Update, validateUpdate, validateWebNotification, WebNotification } from '@cleckheaton-ccc-live-scores/schema';
import { push } from './push';
import { getSubscriptions } from './dynamo';
import { sendDeleteSubscriptionMessage } from './sqs';

const getTitle = (update: Update) => {
  switch (update.team) {
    case 'firstTeam':
      return '1st Team';
    case 'secondTeam':
      return '2nd Team';
    default:
      return 'Cleckheaton CC';
  }
};

const getBody = ({ type, text }: Update) => (type === 'wicket' ? `WICKET: ${text}` : text);

const createNotification = (update: Update) => ({ title: getTitle(update), body: getBody(update) });

const handleWebNotification = async (message: unknown) => {
  const webNotification = validateWebNotification(message);
  await push(sendDeleteSubscriptionMessage, webNotification, [webNotification.subscription]);
};

const handleUpdate = async (message: unknown) => push(sendDeleteSubscriptionMessage, createNotification(validateUpdate(message)), await getSubscriptions());

const handleMessage = async (message: Update | WebNotification) => {
  console.log('Received message', message);
  if ('subscription' in message) {
    return handleWebNotification(message);
  }

  return handleUpdate(message);
};

export const handler = async ({ Records }) => {
  await Promise.all(Records.map(({ body }) => handleMessage(JSON.parse(body))));
};
