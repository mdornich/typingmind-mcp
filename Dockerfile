# Use official Node image
FROM node:20

# Set working directory
WORKDIR /app

# Enable and install pnpm
RUN corepack enable && corepack prepare pnpm@latest --activate

# Copy and install only dependencies
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --prod

# Copy the rest of the code
COPY . .

# Expose port
EXPOSE 8080

# Start server
CMD ["node", "bin/index.js"]
