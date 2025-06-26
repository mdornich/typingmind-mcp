# Use Node.js 18 base image
FROM node:18

# Set the working directory
WORKDIR /app

# Copy package.json and install dependencies
COPY package.json ./

RUN npm install --production && \
    echo "Installed packages:" && \
    ls -la node_modules

# Copy the rest of the project
COPY . .

# Set entrypoint
CMD ["npm", "start"]
