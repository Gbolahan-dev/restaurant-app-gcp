# ---- Base Stage ----
FROM node:20-alpine AS base
RUN npm install -g pnpm
WORKDIR /usr/src/app

# ---- Dependencies Stage ----
# Install ALL dependencies, including dev dependencies, needed for the build.
FROM base AS deps
COPY package.json pnpm-lock.yaml* ./
RUN pnpm install --frozen-lockfile

# ---- Builder Stage ----
# Build the application using the full dependencies.
FROM base AS builder
COPY --from=deps /usr/src/app/node_modules ./node_modules
COPY . .
RUN pnpm prisma generate
RUN pnpm build

# ---- Production Stage ----
# Create the final, small image.
FROM base AS production
ENV NODE_ENV=production

# Copy package manifests for a clean production install.
COPY package.json pnpm-lock.yaml* ./

# Install ONLY production dependencies. This is reliable.
RUN pnpm install --prod --frozen-lockfile

# Copy the pre-built application and other required assets from the builder stage.
COPY --from=builder /usr/src/app/dist ./dist
COPY --from=builder /usr/src/app/prisma ./prisma
# THIS IS THE ONE-LINE FIX. The destination is ./generated, NOT ./dist/generated
COPY --from=builder /usr/src/app/generated ./generated

# This command runs the application.
CMD ["sh", "-c", "pnpm prisma migrate deploy && node dist/main"]
