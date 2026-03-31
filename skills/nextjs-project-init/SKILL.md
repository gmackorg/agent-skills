---
name: nextjs-project-init
description: Initialize a production-ready Next.js web application with TypeScript, an application auth layer, Stripe payments, and database setup. Use when creating SaaS applications, e-commerce sites, or full-stack web applications.
allowed-tools: fs_read fs_write execute_bash
metadata:
  author: kiro-cli
  version: "1.0"
  category: fullstack
  compatibility: Requires Node.js, npm/pnpm, and database (PostgreSQL recommended)
---

# Next.js Project Initialization

## Instructions

1. **Create Next.js project**
```bash
npx create-next-app@latest my-app --typescript --tailwind --app --eslint
cd my-app
```

2. **Install core dependencies**
```bash
npm install stripe prisma @prisma/client
npm install -D prisma
```

3. **Set up environment variables**
Create `.env.local`:
```env
AUTH_SECRET=replace-me
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=pk_test_...
STRIPE_SECRET_KEY=sk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...
DATABASE_URL="postgresql://user:password@localhost:5432/mydb"
NEXT_PUBLIC_APP_URL=http://localhost:3000
```

4. **Configure your auth layer**
Create `src/middleware.ts`:
```typescript
import { auth } from "@/lib/auth";
import { NextResponse } from "next/server";
import type { NextRequest } from "next/server";

const publicPaths = new Set(["/", "/pricing"]);

export async function middleware(req: NextRequest) {
  const session = await auth.api.getSession({ headers: req.headers });

  if (!session && !publicPaths.has(req.nextUrl.pathname) && !req.nextUrl.pathname.startsWith("/api/webhooks/stripe")) {
    return NextResponse.redirect(new URL("/sign-in", req.url));
  }

  return NextResponse.next();
}

export const config = {
  matcher: ["/((?!.+\\.[\\w]+$|_next).*)", "/", "/(api|trpc)(.*)"],
};
```

Create `src/lib/auth.ts` using your preferred auth stack such as `better-auth`.

Update `src/app/layout.tsx`:
```typescript
import type { ReactNode } from "react";

export default function RootLayout({ children }: { children: ReactNode }) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
```

5. **Set up Prisma database**
```bash
npx prisma init
```

Create schema in `prisma/schema.prisma`:
```prisma
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model User {
  id        String   @id @default(cuid())
  authUserId String  @unique
  email     String   @unique
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
  
  subscriptions Subscription[]
}

model Subscription {
  id                     String   @id @default(cuid())
  userId                 String
  stripeCustomerId       String   @unique
  stripeSubscriptionId   String   @unique
  stripePriceId          String
  stripeCurrentPeriodEnd DateTime
  status                 String
  createdAt              DateTime @default(now())
  updatedAt              DateTime @updatedAt
  
  user User @relation(fields: [userId], references: [id], onDelete: Cascade)
}
```

Run migrations:
```bash
npx prisma migrate dev --name init
npx prisma generate
```

6. **Create database client**
Create `src/lib/db.ts`:
```typescript
import { PrismaClient } from '@prisma/client';

const globalForPrisma = globalThis as unknown as {
  prisma: PrismaClient | undefined;
};

export const db = globalForPrisma.prisma ?? new PrismaClient();

if (process.env.NODE_ENV !== 'production') globalForPrisma.prisma = db;
```

7. **Create authentication pages**
Create `src/app/sign-in/[[...sign-in]]/page.tsx`:
```typescript
import Link from "next/link";

export default function Page() {
  return (
    <div className="mx-auto flex min-h-screen max-w-md flex-col items-center justify-center gap-4 p-8 text-center">
      <h1 className="text-2xl font-semibold">Sign in</h1>
      <p>Wire this page to your auth layer or redirect into your auth provider.</p>
      <Link className="rounded bg-black px-4 py-2 text-white" href="/api/auth/sign-in">
        Continue
      </Link>
    </div>
  );
}
```

8. **Create dashboard page**
Create `src/app/dashboard/page.tsx`:
```typescript
import { redirect } from "next/navigation";
import { auth } from "@/lib/auth";

export default async function DashboardPage() {
  const session = await auth.api.getSession({
    headers: new Headers(),
  });
  if (!session) redirect("/sign-in");

  return (
    <div className="container mx-auto p-8">
      <h1 className="text-3xl font-bold">Dashboard</h1>
      <p className="mt-4">Welcome back.</p>
    </div>
  );
}
```

9. **Run development server**
```bash
npm run dev
```

## Examples

### Quick SaaS Setup
```bash
npx create-next-app@latest my-saas --typescript --tailwind --app
cd my-saas
npm install stripe prisma @prisma/client
npx prisma init
# Configure .env.local with auth, Stripe, and database settings
npm run dev
```

### With pnpm
```bash
pnpm create next-app my-app --typescript --tailwind --app
cd my-app
pnpm add stripe @prisma/client
pnpm add -D prisma
pnpm dev
```

## Troubleshooting

- **Auth middleware not working**: Verify your auth helper, middleware path, and session-reading logic
- **Prisma client not found**: Run `npx prisma generate`
- **Database connection fails**: Verify DATABASE_URL format, ensure database is running
- **Stripe keys not working**: Verify test keys (pk_test_, sk_test_), restart dev server
- **Build fails**: Clear .next folder, delete node_modules and reinstall
