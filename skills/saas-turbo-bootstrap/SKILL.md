---
name: saas-turbo-bootstrap
description: Bootstrap a complete SaaS application using Turborepo with Next.js backend, Expo mobile app, an app-level auth layer, Stripe payments, Turso database, Sentry monitoring, PostHog analytics, tRPC, and TanStack Query.
allowed-tools: fs_read fs_write execute_bash
metadata:
  author: kiro-cli
  version: "1.0"
  category: fullstack
  compatibility: Requires Node.js 18+, pnpm, Turbo CLI
---

# SaaS Turborepo Bootstrap

## Instructions

### 1. Initialize Turborepo monorepo

**Create new Turborepo:**
```bash
# Install Turbo CLI
npm install -g turbo

# Create monorepo
npx create-turbo@latest my-saas-app --package-manager pnpm
cd my-saas-app

# Clean up default apps
rm -rf apps/web apps/docs
```

**Configure workspace structure:**
```json
// package.json
{
  "name": "my-saas-app",
  "private": true,
  "workspaces": [
    "apps/*",
    "packages/*"
  ],
  "scripts": {
    "build": "turbo build",
    "dev": "turbo dev",
    "lint": "turbo lint",
    "type-check": "turbo type-check",
    "clean": "turbo clean"
  },
  "devDependencies": {
    "turbo": "^1.10.0",
    "@turbo/gen": "^1.10.0"
  },
  "packageManager": "pnpm@8.0.0"
}
```

**Configure turbo.json:**
```json
{
  "$schema": "https://turbo.build/schema.json",
  "globalDependencies": ["**/.env.*local"],
  "pipeline": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": [".next/**", "!.next/cache/**", "dist/**"]
    },
    "dev": {
      "cache": false,
      "persistent": true
    },
    "lint": {},
    "type-check": {}
  }
}
```

### 2. Create Next.js backend app

**Initialize Next.js app:**
```bash
mkdir -p apps/web
cd apps/web
npx create-next-app@latest . --typescript --tailwind --app --eslint
```

**Configure package.json:**
```json
{
  "name": "web",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "dev": "next dev --port 3000",
    "build": "next build",
    "start": "next start",
    "lint": "next lint",
    "type-check": "tsc --noEmit"
  },
  "dependencies": {
    "next": "14.0.0",
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "@trpc/server": "^10.45.0",
    "@trpc/client": "^10.45.0",
    "@trpc/next": "^10.45.0",
    "@trpc/react-query": "^10.45.0",
    "@tanstack/react-query": "^5.0.0",
    "stripe": "^14.0.0",
    "@libsql/client": "^0.4.0",
    "drizzle-orm": "^0.29.0",
    "@sentry/nextjs": "^7.80.0",
    "posthog-js": "^1.90.0"
  },
  "devDependencies": {
    "@types/node": "^20.0.0",
    "@types/react": "^18.2.0",
    "@types/react-dom": "^18.2.0",
    "drizzle-kit": "^0.20.0",
    "typescript": "^5.0.0"
  }
}
```

### 3. Create Expo mobile app

**Initialize Expo app:**
```bash
cd ../../
mkdir -p apps/mobile
cd apps/mobile
npx create-expo-app@latest . --template blank-typescript
```

**Configure package.json:**
```json
{
  "name": "mobile",
  "version": "1.0.0",
  "main": "node_modules/expo/AppEntry.js",
  "scripts": {
    "start": "expo start",
    "android": "expo start --android",
    "ios": "expo start --ios",
    "web": "expo start --web",
    "build": "expo export",
    "type-check": "tsc --noEmit"
  },
  "dependencies": {
    "expo": "~49.0.0",
    "react": "18.2.0",
    "react-native": "0.72.0",
    "@trpc/client": "^10.45.0",
    "@trpc/react-query": "^10.45.0",
    "@tanstack/react-query": "^5.0.0",
    "expo-secure-store": "~12.3.1",
    "expo-web-browser": "~12.3.2",
    "@react-navigation/native": "^6.1.0",
    "@react-navigation/native-stack": "^6.9.0",
    "@sentry/react-native": "^5.15.0",
    "posthog-react-native": "^3.0.0"
  },
  "devDependencies": {
    "@types/react": "~18.2.0",
    "typescript": "^5.0.0"
  }
}
```

### 4. Set up shared packages

**Create shared tRPC package:**
```bash
mkdir -p packages/api
cd packages/api
```

**packages/api/package.json:**
```json
{
  "name": "api",
  "version": "0.1.0",
  "main": "./src/index.ts",
  "types": "./src/index.ts",
  "dependencies": {
    "@trpc/server": "^10.45.0",
    "zod": "^3.22.0",
    "drizzle-orm": "^0.29.0",
    "@libsql/client": "^0.4.0"
  },
  "devDependencies": {
    "typescript": "^5.0.0"
  }
}
```

**tRPC router setup:**
```typescript
// packages/api/src/index.ts
export * from './router';
export * from './context';
export type { AppRouter } from './router';

// packages/api/src/context.ts
import { auth } from '../auth';
import { db } from './db';

export async function createContext() {
  const session = await auth.api.getSession();
  const userId = session?.user?.id ?? null;
  
  return {
    db,
    userId,
  };
}

export type Context = Awaited<ReturnType<typeof createContext>>;

// packages/api/src/router.ts
import { initTRPC, TRPCError } from '@trpc/server';
import { z } from 'zod';
import type { Context } from './context';

const t = initTRPC.context<Context>().create();

const protectedProcedure = t.procedure.use(({ ctx, next }) => {
  if (!ctx.userId) {
    throw new TRPCError({ code: 'UNAUTHORIZED' });
  }
  return next({ ctx: { ...ctx, userId: ctx.userId } });
});

export const appRouter = t.router({
  user: t.router({
    getProfile: protectedProcedure.query(async ({ ctx }) => {
      return await ctx.db.user.findUnique({
        where: { authUserId: ctx.userId },
      });
    }),
    
    updateProfile: protectedProcedure
      .input(z.object({
        name: z.string().min(1),
        email: z.string().email(),
      }))
      .mutation(async ({ ctx, input }) => {
        return await ctx.db.user.update({
          where: { authUserId: ctx.userId },
          data: input,
        });
      }),
  }),
  
  subscription: t.router({
    getCurrent: protectedProcedure.query(async ({ ctx }) => {
      return await ctx.db.subscription.findFirst({
        where: { userId: ctx.userId },
      });
    }),
  }),
});

export type AppRouter = typeof appRouter;
```

**Create database package:**
```bash
mkdir -p packages/db
cd packages/db
```

**packages/db/package.json:**
```json
{
  "name": "db",
  "version": "0.1.0",
  "main": "./src/index.ts",
  "dependencies": {
    "drizzle-orm": "^0.29.0",
    "@libsql/client": "^0.4.0"
  },
  "devDependencies": {
    "drizzle-kit": "^0.20.0",
    "typescript": "^5.0.0"
  }
}
```

**Database schema:**
```typescript
// packages/db/src/schema.ts
import { sqliteTable, text, integer } from 'drizzle-orm/sqlite-core';

export const users = sqliteTable('users', {
  id: text('id').primaryKey(),
  authUserId: text('auth_user_id').unique().notNull(),
  email: text('email').notNull(),
  name: text('name'),
  createdAt: integer('created_at', { mode: 'timestamp' }).notNull(),
  updatedAt: integer('updated_at', { mode: 'timestamp' }).notNull(),
});

export const subscriptions = sqliteTable('subscriptions', {
  id: text('id').primaryKey(),
  userId: text('user_id').references(() => users.id).notNull(),
  stripeCustomerId: text('stripe_customer_id').unique(),
  stripeSubscriptionId: text('stripe_subscription_id').unique(),
  stripePriceId: text('stripe_price_id'),
  status: text('status').notNull(),
  currentPeriodStart: integer('current_period_start', { mode: 'timestamp' }),
  currentPeriodEnd: integer('current_period_end', { mode: 'timestamp' }),
  createdAt: integer('created_at', { mode: 'timestamp' }).notNull(),
  updatedAt: integer('updated_at', { mode: 'timestamp' }).notNull(),
});

// packages/db/src/index.ts
import { drizzle } from 'drizzle-orm/libsql';
import { createClient } from '@libsql/client';
import * as schema from './schema';

const client = createClient({
  url: process.env.TURSO_DATABASE_URL!,
  authToken: process.env.TURSO_AUTH_TOKEN!,
});

export const db = drizzle(client, { schema });
export * from './schema';
```

### 5. Configure environment variables

**Root .env.example:**
```env
# Auth
AUTH_SECRET=replace-me
AUTH_URL=http://localhost:3000

# Stripe
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=pk_test_...
STRIPE_SECRET_KEY=sk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...

# Turso Database
TURSO_DATABASE_URL=libsql://...
TURSO_AUTH_TOKEN=...

# Sentry
NEXT_PUBLIC_SENTRY_DSN=https://...
SENTRY_AUTH_TOKEN=...

# PostHog
NEXT_PUBLIC_POSTHOG_KEY=phc_...
NEXT_PUBLIC_POSTHOG_HOST=https://app.posthog.com

# Expo
EXPO_PUBLIC_AUTH_URL=http://localhost:3000
EXPO_PUBLIC_API_URL=http://localhost:3000
```

### 6. Set up monitoring and analytics

**Sentry configuration for Next.js:**
```javascript
// apps/web/sentry.client.config.js
import * as Sentry from '@sentry/nextjs';

Sentry.init({
  dsn: process.env.NEXT_PUBLIC_SENTRY_DSN,
  tracesSampleRate: 1.0,
  environment: process.env.NODE_ENV,
});

// apps/web/sentry.server.config.js
import * as Sentry from '@sentry/nextjs';

Sentry.init({
  dsn: process.env.NEXT_PUBLIC_SENTRY_DSN,
  tracesSampleRate: 1.0,
  environment: process.env.NODE_ENV,
});
```

**PostHog setup:**
```typescript
// packages/analytics/src/index.ts
import posthog from 'posthog-js';

export function initPostHog() {
  if (typeof window !== 'undefined') {
    posthog.init(process.env.NEXT_PUBLIC_POSTHOG_KEY!, {
      api_host: process.env.NEXT_PUBLIC_POSTHOG_HOST,
    });
  }
}

export { posthog };
```

### 7. Development scripts

**Root package.json scripts:**
```json
{
  "scripts": {
    "dev": "turbo dev",
    "build": "turbo build",
    "db:generate": "cd packages/db && drizzle-kit generate:sqlite",
    "db:migrate": "cd packages/db && drizzle-kit push:sqlite",
    "db:studio": "cd packages/db && drizzle-kit studio",
    "type-check": "turbo type-check",
    "lint": "turbo lint",
    "clean": "turbo clean && rm -rf node_modules"
  }
}
```

**Development startup script:**
```bash
#!/bin/bash
# scripts/dev.sh

echo "🚀 Starting SaaS development environment..."

# Check if .env files exist
if [ ! -f "apps/web/.env.local" ]; then
  echo "⚠️  Creating .env.local files from .env.example"
  cp .env.example apps/web/.env.local
  cp .env.example apps/mobile/.env.local
fi

# Install dependencies
echo "📦 Installing dependencies..."
pnpm install

# Generate database
echo "🗄️  Setting up database..."
pnpm db:generate
pnpm db:migrate

# Start development servers
echo "🔥 Starting development servers..."
pnpm dev
```

### 8. Deployment configuration

**Vercel deployment for Next.js:**
```json
// apps/web/vercel.json
{
  "buildCommand": "cd ../.. && pnpm build --filter=web",
  "outputDirectory": ".next",
  "installCommand": "cd ../.. && pnpm install",
  "framework": "nextjs"
}
```

**EAS configuration for Expo:**
```json
// apps/mobile/eas.json
{
  "cli": {
    "version": ">= 5.4.0"
  },
  "build": {
    "development": {
      "developmentClient": true,
      "distribution": "internal"
    },
    "preview": {
      "distribution": "internal"
    },
    "production": {}
  },
  "submit": {
    "production": {}
  }
}
```

## Examples

### Complete setup command
```bash
# Clone and setup
git clone <your-repo>
cd my-saas-app
chmod +x scripts/dev.sh
./scripts/dev.sh
```

### Adding new features
```bash
# Add new tRPC router
cd packages/api/src/routers
# Create new router file

# Add new database table
cd packages/db/src
# Update schema.ts
pnpm db:generate
pnpm db:migrate
```

### Mobile app development
```bash
# Start Expo dev server
cd apps/mobile
pnpm start

# Build for testing
pnpm build
eas build --profile preview
```

## Troubleshooting

- **Turbo cache issues**: Run `turbo clean` and restart
- **Database connection fails**: Check Turso credentials and network
- **tRPC type errors**: Ensure API package is built before web/mobile
- **Auth flow not working**: Verify your auth library configuration, session helpers, and middleware
- **Stripe webhooks failing**: Check webhook endpoints and secrets
- **Mobile app not connecting**: Verify API_URL points to correct backend
- **Build failures**: Check workspace dependencies and TypeScript config
