# ---- Base Stage ----
# Start with a modern Node.js version that includes pnpm.
FROM node:20-alpine AS base
RUN npm install -g pnpm
WORKDIR /usr/src/app

# ---- Dependencies Stage ----
# Copy only the dependency manifests and install.
# This layer is cached and only re-runs if package.json or pnpm-lock.yaml change.
FROM base AS deps
COPY package.json pnpm-lock.yaml* ./
# Install ALL dependencies needed for the build step
RUN pnpm install --frozen-lockfile

# ---- Builder Stage ----
# This stage builds the application and generates the Prisma client.
FROM base AS builder
# Copy dependencies and source code
COPY --from=deps /usr/src/app/node_modules ./node_modules
COPY . .
# Generate the Prisma client based on the schema
RUN pnpm prisma generate
# Build the NestJS application (compiles TypeScript to JavaScript)
RUN pnpm build

# ---- Production Stage ----
FROM node:20-alpine AS production
RUN npm install -g pnpm
WORKDIR /usr/src/app
ENV NODE_ENV=production

# Copy build outputs
COPY --from=builder /usr/src/app/dist     ./dist
COPY --from=builder /usr/src/app/prisma   ./prisma
COPY --from=builder /usr/src/app/generated ./dist/generated

# Copy manifests for installing deps
COPY package.json pnpm-lock.yaml ./

# Install production dependencies
RUN pnpm install --prod --frozen-lockfile

# Entrypoint
CMD ["sh", "-c", "pnpm prisma migrate deploy && node dist/main"]

