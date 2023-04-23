import webpush, { PushSubscription } from 'web-push';

const vapidSubject = `${process.env.VAPID_SUBJECT}`;
const vapidPublicKey = `${process.env.VAPID_PUBLIC_KEY}`;
const vapidPrivateKey = `${process.env.VAPID_PRIVATE_KEY}`;

webpush.setVapidDetails(vapidSubject, vapidPublicKey, vapidPrivateKey);

export const push = async (notification: { title: string; body: string }, subscriptions: PushSubscription[]) => {
  console.log('Sending notification', notification);
  await Promise.all(subscriptions.map(subscription => webpush.sendNotification(subscription, JSON.stringify(notification))));
};
