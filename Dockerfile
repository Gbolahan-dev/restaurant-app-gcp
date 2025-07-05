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
# This is the final, small, secure image that will be deployed.
FROM base AS production
ENV NODE_ENV=production
# Copy only the production dependencies from the 'deps' stage
COPY --from=deps /usr/src/app/node_modules ./node_modules
# Copy the compiled application code from the 'builder' stage
COPY --from=builder /usr/src/app/dist ./dist
# Copy the prisma schema, which is needed for running migrations
COPY --from=builder /usr/src/app/prisma ./prisma
# ADD THIS LINE in the 'production' stage
COPY --from=builder /usr/src/app/generated ./generated
# Copy package.json to know which prod dependencies to keep
COPY package.json .
# Prune development dependencies
RUN pnpm prune --prod

# This is the command that will be run when the container starts.
# It first applies any pending database migrations, then starts the app.
CMD ["sh", "-c", "pnpm prisma migrate deploy && node dist/main"]
