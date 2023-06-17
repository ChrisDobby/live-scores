import { z } from 'zod';

const SubscriptionSchema = z.object({
  endpoint: z.string(),
  keys: z.object({
    p256dh: z.string(),
    auth: z.string(),
  }),
});

const WebNotificationSchema = z.object({
  subscription: SubscriptionSchema,
  title: z.string(),
  body: z.string(),
});

export type WebNotification = z.infer<typeof WebNotificationSchema>;
export type Subscription = z.infer<typeof SubscriptionSchema>;

export const validateWebNotification = (webNotification: unknown): WebNotification => WebNotificationSchema.parse(webNotification);
export const validateSubscription = (subscription: unknown) => SubscriptionSchema.safeParse(subscription);
