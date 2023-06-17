import webpush, { PushSubscription, WebPushError } from 'web-push';

const vapidSubject = `${process.env.VAPID_SUBJECT}`;
const vapidPublicKey = `${process.env.VAPID_PUBLIC_KEY}`;
const vapidPrivateKey = `${process.env.VAPID_PRIVATE_KEY}`;

webpush.setVapidDetails(vapidSubject, vapidPublicKey, vapidPrivateKey);

type RemoveSubscription = (subscription: string) => Promise<void>;
const send = (removeSubscription: RemoveSubscription, notification: string) => async (subscription: PushSubscription) => {
  try {
    await webpush.sendNotification(subscription, notification);
  } catch (e: unknown) {
    if (e instanceof WebPushError && (e.body.includes('unsubscribed') || e.body.includes('expired'))) {
      console.log(`Removing subscription ${subscription.endpoint}`);
      removeSubscription(subscription.endpoint);
    } else {
      console.log(e);
    }
  }
};

export const push = async (removeSubscription: RemoveSubscription, notification: { title: string; body: string }, subscriptions: PushSubscription[]) => {
  console.log('Sending notification', notification);
  await Promise.all(subscriptions.map(send(removeSubscription, JSON.stringify(notification))));
};
