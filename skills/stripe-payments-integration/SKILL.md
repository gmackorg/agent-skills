---
name: stripe-payments-integration
description: Integrate Stripe payments into Next.js and Expo applications with subscriptions, one-time payments, webhooks, and customer management. Use for SaaS billing and e-commerce.
allowed-tools: fs_read fs_write execute_bash
metadata:
  author: kiro-cli
  version: "1.0"
  category: fullstack
  compatibility: Requires Stripe account, Next.js or Expo
---

# Stripe Payments Integration

## Instructions

### 1. Next.js Stripe Setup

**Install Stripe dependencies:**
```bash
npm install stripe @stripe/stripe-js @stripe/react-stripe-js
```

**Configure Stripe client:**
```typescript
// lib/stripe.ts
import { loadStripe } from '@stripe/stripe-js';
import Stripe from 'stripe';

// Client-side Stripe
export const stripePromise = loadStripe(
  process.env.NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY!
);

// Server-side Stripe
export const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!, {
  apiVersion: '2023-10-16',
});
```

**Subscription checkout API:**
```typescript
// app/api/stripe/create-checkout/route.ts
import { NextRequest, NextResponse } from 'next/server';
import { stripe } from '@/lib/stripe';
import { auth } from '@/lib/auth';
import { db } from '@/lib/db';

export async function POST(req: NextRequest) {
  try {
    const session = await auth.api.getSession({ headers: req.headers });
    const userId = session?.user?.id;
    if (!session || !userId) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    const { priceId, successUrl, cancelUrl } = await req.json();

    // Get or create Stripe customer
    let customer = await db.user.findUnique({
      where: { authUserId: userId },
      select: { stripeCustomerId: true, email: true },
    });

    if (!customer?.stripeCustomerId) {
      const stripeCustomer = await stripe.customers.create({
        email: customer?.email,
        metadata: { authUserId: userId },
      });

      await db.user.update({
        where: { authUserId: userId },
        data: { stripeCustomerId: stripeCustomer.id },
      });

      customer = { ...customer, stripeCustomerId: stripeCustomer.id };
    }

    // Create checkout session
    const session = await stripe.checkout.sessions.create({
      customer: customer.stripeCustomerId,
      payment_method_types: ['card'],
      line_items: [
        {
          price: priceId,
          quantity: 1,
        },
      ],
      mode: 'subscription',
      success_url: successUrl,
      cancel_url: cancelUrl,
      metadata: {
        userId,
      },
    });

    return NextResponse.json({ sessionId: session.id });
  } catch (error) {
    console.error('Stripe checkout error:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}
```

**Checkout component:**
```typescript
// components/SubscriptionCheckout.tsx
import { useState } from 'react';
import { loadStripe } from '@stripe/stripe-js';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';

const stripePromise = loadStripe(process.env.NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY!);

interface Plan {
  id: string;
  name: string;
  price: number;
  priceId: string;
  features: string[];
}

const plans: Plan[] = [
  {
    id: 'basic',
    name: 'Basic',
    price: 9.99,
    priceId: 'price_basic',
    features: ['Feature 1', 'Feature 2', 'Feature 3'],
  },
  {
    id: 'pro',
    name: 'Pro',
    price: 19.99,
    priceId: 'price_pro',
    features: ['All Basic features', 'Feature 4', 'Feature 5'],
  },
];

export function SubscriptionCheckout() {
  const [loading, setLoading] = useState<string | null>(null);

  const handleCheckout = async (priceId: string, planId: string) => {
    setLoading(planId);

    try {
      const response = await fetch('/api/stripe/create-checkout', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          priceId,
          successUrl: `${window.location.origin}/dashboard?success=true`,
          cancelUrl: `${window.location.origin}/pricing?canceled=true`,
        }),
      });

      const { sessionId } = await response.json();
      const stripe = await stripePromise;
      
      await stripe?.redirectToCheckout({ sessionId });
    } catch (error) {
      console.error('Checkout error:', error);
    } finally {
      setLoading(null);
    }
  };

  return (
    <div className="grid md:grid-cols-2 gap-6">
      {plans.map((plan) => (
        <Card key={plan.id}>
          <CardHeader>
            <CardTitle>{plan.name}</CardTitle>
            <div className="text-3xl font-bold">${plan.price}/month</div>
          </CardHeader>
          <CardContent>
            <ul className="space-y-2 mb-6">
              {plan.features.map((feature, index) => (
                <li key={index} className="flex items-center">
                  <span className="mr-2">✓</span>
                  {feature}
                </li>
              ))}
            </ul>
            <Button
              onClick={() => handleCheckout(plan.priceId, plan.id)}
              disabled={loading === plan.id}
              className="w-full"
            >
              {loading === plan.id ? 'Processing...' : 'Subscribe'}
            </Button>
          </CardContent>
        </Card>
      ))}
    </div>
  );
}
```

### 2. Stripe Webhooks

**Webhook handler:**
```typescript
// app/api/webhooks/stripe/route.ts
import { NextRequest, NextResponse } from 'next/server';
import { headers } from 'next/headers';
import Stripe from 'stripe';
import { stripe } from '@/lib/stripe';
import { db } from '@/lib/db';

const webhookSecret = process.env.STRIPE_WEBHOOK_SECRET!;

export async function POST(req: NextRequest) {
  const body = await req.text();
  const signature = headers().get('stripe-signature')!;

  let event: Stripe.Event;

  try {
    event = stripe.webhooks.constructEvent(body, signature, webhookSecret);
  } catch (err) {
    console.error('Webhook signature verification failed:', err);
    return NextResponse.json({ error: 'Invalid signature' }, { status: 400 });
  }

  try {
    switch (event.type) {
      case 'checkout.session.completed':
        await handleCheckoutCompleted(event.data.object as Stripe.Checkout.Session);
        break;

      case 'customer.subscription.created':
      case 'customer.subscription.updated':
        await handleSubscriptionChange(event.data.object as Stripe.Subscription);
        break;

      case 'customer.subscription.deleted':
        await handleSubscriptionDeleted(event.data.object as Stripe.Subscription);
        break;

      case 'invoice.payment_succeeded':
        await handlePaymentSucceeded(event.data.object as Stripe.Invoice);
        break;

      case 'invoice.payment_failed':
        await handlePaymentFailed(event.data.object as Stripe.Invoice);
        break;

      default:
        console.log(`Unhandled event type: ${event.type}`);
    }

    return NextResponse.json({ received: true });
  } catch (error) {
    console.error('Webhook handler error:', error);
    return NextResponse.json({ error: 'Webhook handler failed' }, { status: 500 });
  }
}

async function handleCheckoutCompleted(session: Stripe.Checkout.Session) {
  const userId = session.metadata?.userId;
  if (!userId) return;

  // Update user's subscription status
  await db.user.update({
    where: { authUserId: userId },
    data: { 
      stripeCustomerId: session.customer as string,
      subscriptionStatus: 'active',
    },
  });
}

async function handleSubscriptionChange(subscription: Stripe.Subscription) {
  const customer = await stripe.customers.retrieve(subscription.customer as string);
  
  if (customer.deleted) return;

  const userId = customer.metadata?.authUserId;
  if (!userId) return;

  await db.subscription.upsert({
    where: { stripeSubscriptionId: subscription.id },
    update: {
      status: subscription.status,
      currentPeriodStart: new Date(subscription.current_period_start * 1000),
      currentPeriodEnd: new Date(subscription.current_period_end * 1000),
      stripePriceId: subscription.items.data[0]?.price.id,
    },
    create: {
      userId,
      stripeCustomerId: subscription.customer as string,
      stripeSubscriptionId: subscription.id,
      status: subscription.status,
      currentPeriodStart: new Date(subscription.current_period_start * 1000),
      currentPeriodEnd: new Date(subscription.current_period_end * 1000),
      stripePriceId: subscription.items.data[0]?.price.id,
    },
  });
}
```

### 3. Customer Portal

**Customer portal API:**
```typescript
// app/api/stripe/create-portal/route.ts
import { NextRequest, NextResponse } from 'next/server';
import { stripe } from '@/lib/stripe';
import { auth } from '@/lib/auth';
import { db } from '@/lib/db';

export async function POST(req: NextRequest) {
  try {
    const session = await auth.api.getSession({ headers: req.headers });
    const userId = session?.user?.id;
    if (!session || !userId) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    const user = await db.user.findUnique({
      where: { authUserId: userId },
      select: { stripeCustomerId: true },
    });

    if (!user?.stripeCustomerId) {
      return NextResponse.json({ error: 'No customer found' }, { status: 404 });
    }

    const { returnUrl } = await req.json();

    const session = await stripe.billingPortal.sessions.create({
      customer: user.stripeCustomerId,
      return_url: returnUrl || `${process.env.NEXT_PUBLIC_APP_URL}/dashboard`,
    });

    return NextResponse.json({ url: session.url });
  } catch (error) {
    console.error('Portal creation error:', error);
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 });
  }
}
```

**Portal button component:**
```typescript
// components/CustomerPortalButton.tsx
import { useState } from 'react';
import { Button } from '@/components/ui/button';

export function CustomerPortalButton() {
  const [loading, setLoading] = useState(false);

  const handlePortal = async () => {
    setLoading(true);

    try {
      const response = await fetch('/api/stripe/create-portal', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          returnUrl: window.location.href,
        }),
      });

      const { url } = await response.json();
      window.location.href = url;
    } catch (error) {
      console.error('Portal error:', error);
    } finally {
      setLoading(false);
    }
  };

  return (
    <Button onClick={handlePortal} disabled={loading} variant="outline">
      {loading ? 'Loading...' : 'Manage Subscription'}
    </Button>
  );
}
```

### 4. Expo Stripe Integration

**Install Stripe for Expo:**
```bash
npx expo install @stripe/stripe-react-native
```

**Configure Stripe provider:**
```typescript
// App.tsx
import { StripeProvider } from '@stripe/stripe-react-native';

export default function App() {
  return (
    <StripeProvider
      publishableKey={process.env.EXPO_PUBLIC_STRIPE_PUBLISHABLE_KEY!}
      merchantIdentifier="merchant.com.yourapp"
    >
      <YourAppContent />
    </StripeProvider>
  );
}
```

**Payment screen:**
```typescript
// screens/PaymentScreen.tsx
import { useState } from 'react';
import { View, Alert } from 'react-native';
import { useStripe } from '@stripe/stripe-react-native';
import { Button } from '../components/Button';

export function PaymentScreen() {
  const { initPaymentSheet, presentPaymentSheet } = useStripe();
  const [loading, setLoading] = useState(false);

  const initializePaymentSheet = async () => {
    const response = await fetch('/api/stripe/payment-sheet', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ amount: 1999 }), // $19.99
    });

    const { paymentIntent, ephemeralKey, customer } = await response.json();

    const { error } = await initPaymentSheet({
      merchantDisplayName: 'Your App',
      customerId: customer,
      customerEphemeralKeySecret: ephemeralKey,
      paymentIntentClientSecret: paymentIntent,
      allowsDelayedPaymentMethods: true,
    });

    if (error) {
      Alert.alert('Error', error.message);
    }
  };

  const openPaymentSheet = async () => {
    setLoading(true);
    await initializePaymentSheet();

    const { error } = await presentPaymentSheet();

    if (error) {
      Alert.alert('Payment failed', error.message);
    } else {
      Alert.alert('Success', 'Payment completed!');
    }

    setLoading(false);
  };

  return (
    <View style={{ flex: 1, justifyContent: 'center', padding: 20 }}>
      <Button
        title={loading ? 'Processing...' : 'Pay $19.99'}
        onPress={openPaymentSheet}
        disabled={loading}
      />
    </View>
  );
}
```

### 5. Subscription Management

**Subscription status component:**
```typescript
// components/SubscriptionStatus.tsx
import { useQuery } from '@tanstack/react-query';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { CustomerPortalButton } from './CustomerPortalButton';

export function SubscriptionStatus() {
  const { data: subscription, isLoading } = useQuery({
    queryKey: ['subscription'],
    queryFn: async () => {
      const response = await fetch('/api/subscription');
      return response.json();
    },
  });

  if (isLoading) {
    return <div>Loading subscription...</div>;
  }

  if (!subscription) {
    return (
      <Card>
        <CardHeader>
          <CardTitle>No Active Subscription</CardTitle>
        </CardHeader>
        <CardContent>
          <p>You don't have an active subscription.</p>
        </CardContent>
      </Card>
    );
  }

  return (
    <Card>
      <CardHeader>
        <CardTitle>Subscription Status</CardTitle>
      </CardHeader>
      <CardContent className="space-y-4">
        <div className="flex items-center justify-between">
          <span>Status:</span>
          <Badge variant={subscription.status === 'active' ? 'default' : 'destructive'}>
            {subscription.status}
          </Badge>
        </div>
        
        <div className="flex items-center justify-between">
          <span>Current Period:</span>
          <span>
            {new Date(subscription.currentPeriodStart).toLocaleDateString()} - 
            {new Date(subscription.currentPeriodEnd).toLocaleDateString()}
          </span>
        </div>
        
        <CustomerPortalButton />
      </CardContent>
    </Card>
  );
}
```

### 6. Usage-based Billing

**Usage tracking API:**
```typescript
// app/api/stripe/usage/route.ts
import { NextRequest, NextResponse } from 'next/server';
import { stripe } from '@/lib/stripe';
import { auth } from '@/lib/auth';
import { db } from '@/lib/db';

export async function POST(req: NextRequest) {
  try {
    const session = await auth.api.getSession({ headers: req.headers });
    const userId = session?.user?.id;
    if (!session || !userId) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    const { quantity, action } = await req.json();

    // Get user's subscription
    const subscription = await db.subscription.findFirst({
      where: { userId },
      include: { user: true },
    });

    if (!subscription?.stripeSubscriptionId) {
      return NextResponse.json({ error: 'No subscription found' }, { status: 404 });
    }

    // Record usage
    await stripe.subscriptionItems.createUsageRecord(
      subscription.stripeSubscriptionItemId,
      {
        quantity,
        timestamp: Math.floor(Date.now() / 1000),
        action: action || 'increment',
      }
    );

    return NextResponse.json({ success: true });
  } catch (error) {
    console.error('Usage tracking error:', error);
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 });
  }
}
```

## Examples

### Complete checkout flow
```typescript
// Pricing page with checkout
export function PricingPage() {
  return (
    <div className="container mx-auto py-12">
      <h1 className="text-4xl font-bold text-center mb-12">Choose Your Plan</h1>
      <SubscriptionCheckout />
    </div>
  );
}
```

### Dashboard with subscription management
```typescript
// Dashboard with subscription info
export function Dashboard() {
  return (
    <div className="container mx-auto p-6">
      <h1 className="text-3xl font-bold mb-6">Dashboard</h1>
      <div className="grid gap-6">
        <SubscriptionStatus />
        {/* Other dashboard content */}
      </div>
    </div>
  );
}
```

### Mobile payment integration
```typescript
// Mobile subscription screen
export function SubscriptionScreen() {
  return (
    <View style={{ flex: 1, padding: 20 }}>
      <Text style={{ fontSize: 24, fontWeight: 'bold', marginBottom: 20 }}>
        Upgrade to Pro
      </Text>
      <PaymentScreen />
    </View>
  );
}
```

## Troubleshooting

- **Webhook not receiving events**: Check endpoint URL and webhook secret
- **Payment sheet not loading**: Verify Stripe keys and network connectivity
- **Subscription not updating**: Check webhook event handling and database updates
- **Customer portal not working**: Ensure customer has valid Stripe customer ID
- **Mobile payments failing**: Check bundle identifier and merchant settings
- **Test payments not working**: Use Stripe test card numbers and test keys
