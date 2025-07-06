# ---- Base Stage ----
FROM node:20-alpine AS base
RUN npm install -g pnpm
WORKDIR /usr/src/app

# ---- Builder Stage ----
# Builds a complete, working version of the application
FROM base AS builder
COPY package.json pnpm-lock.yaml* ./
RUN pnpm install --frozen-lockfile

COPY . .
RUN pnpm prisma generate
RUN pnpm build


# ---- Production Stage ----
FROM node:20-alpine AS production
WORKDIR /usr/src/app
ENV NODE_ENV=production

# Copy package manifests for a clean production install
COPY package.json pnpm-lock.yaml* ./
RUN pnpm install --prod --frozen-lockfile

# Copy the pre-built application and other assets from the builder stage
COPY --from=builder /usr/src/app/dist ./dist
COPY --from=builder /usr/src/app/prisma ./prisma
# THIS IS THE CORRECTED LINE:
COPY --from=builder /usr/src/app/generated ./generated

# Set the command to run the application
CMD ["sh", "-c", "pnpm prisma migrate deploy && node dist/main"]
