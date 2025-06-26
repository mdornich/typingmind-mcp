# Use an official Node.js runtime as a parent image (slim variant for better security)
FROM node:23-slim

# Install Python, pip, and other dependencies (still keeping it in case other MCPs use uv)
RUN apt-get update && \
    apt-get install -y python3 python3-pip && \
    rm -rf /var/lib/apt/lists/*

# Install uv via pip
RUN pip3 install uv --break-system-packages 

# Set the working directory in the container
WORKDIR /app

# Install pnpm globally
RUN npm install -g pnpm

# Install all MCP plugins globally so npx doesn't have to fetch them at runtime
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

# Copy credentials file directly into the container at build time
COPY tnt-folder-credentials.json /app/credentials/tnt-folder-credentials.json

# Set environment variables for Railway to expose the correct port and bind externally
ENV PORT=8080
ENV HOSTNAME=0.0.0.0

# Start the MCP runner (auth token can remain hardcoded for now)
CMD ["node", "bin/index.js", "NuKXn-iw1VyQeqUH22aj3"]
