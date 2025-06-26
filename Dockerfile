# Use an official Node.js runtime as a parent image (slim variant for better security)
FROM node:23-slim

# Install Python, pip, and other dependencies
RUN apt-get update && \
    apt-get install -y python3 python3-pip && \
    rm -rf /var/lib/apt/lists/*

# Install uv via pip
RUN pip3 install uv --break-system-packages 

# Set the working directory in the container
WORKDIR /app

# Install pnpm globally
RUN npm install -g pnpm

# Install all MCP plugins globally so npx doesn't have to fetch them
RUN npm install -g \
    @supabase/mcp-server-supabase \
    @notionhq/notion-mcp-server \
    @modelcontextprotocol/server-sequential-thinking \
    @modelcontextprotocol/server-memory \
    @upstash/context7-mcp \
    @clayhq/clay-mcp \
    @modelcontextprotocol/server-gdrive \
    @modelcontextprotocol/server-puppeteer

# Copy package.json and pnpm-lock.yaml first to leverage Docker cache
COPY package.json pnpm-lock.yaml ./

# Install only production dependencies
RUN pnpm install --prod

# Copy the rest of the application source code
COPY . .

# Set environment variables for Railway to expose the correct port and bind externally
ENV PORT=8080
ENV HOSTNAME=0.0.0.0

# Create credentials directory, write JSON from env var, log it for validation, and start the app
CMD mkdir -p /app/credentials && \
    printf "%s" "$GDRIVE_CREDENTIALS_JSON" > /app/credentials/tnt-folder-credentials.json && \
    echo "📄 Dump of GDrive credentials JSON:" && \
    cat /app/credentials/tnt-folder-credentials.json && \
    echo "🚀 Starting MCP server..." && \
    node bin/index.js NuKXn-iw1VyQeqUH22aj3
