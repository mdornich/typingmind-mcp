# Use Node slim base
FROM node:18-slim

# Enable corepack (for pnpm)
RUN corepack enable

# Set working directory
WORKDIR /app

# Copy package manifests first (Docker cache optimization)
COPY package.json pnpm-lock.yaml ./

# Install only production dependencies
RUN pnpm install --prod

# Copy the rest of the app (including bin/index.js)
COPY . .

# Set default start command
CMD ["node", "bin/index.js"]
