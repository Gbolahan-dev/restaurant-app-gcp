# ---- Base Stage ----
FROM node:20-alpine AS base
RUN npm install -g pnpm
WORKDIR /usr/src/app

# ---- Dependencies Stage ----
# First, install dependencies and generate the Prisma Client.
FROM base AS deps
COPY prisma ./prisma/
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile
RUN pnpm prisma generate

# ---- Builder Stage ----
# Use the dependencies from the previous stage to build the app.
FROM base AS builder
COPY . .
COPY --from=deps /usr/src/app/node_modules ./node_modules
COPY --from=deps /usr/src/app/prisma ./prisma
RUN pnpm build

# ---- Production Stage ----
# Create the final, small image.
FROM base AS production
ENV NODE_ENV=production

# Copy the built application from the builder stage.
COPY --from=builder /usr/src/app/dist ./dist

# Copy the prisma schema and the production node_modules.
# Critically, this includes the generated Prisma client.
COPY --from=builder /usr/src/app/prisma ./prisma
COPY --from=builder /usr/src/app/node_modules ./node_modules


# This command runs the application.
CMD ["node", "dist/main.js"]
