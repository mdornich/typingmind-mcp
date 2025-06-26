# Use Node.js 18 base image
FROM node:18

# Set the working directory
WORKDIR /app

# Copy only what's needed to install dependencies
COPY package.json ./

# Install only production dependencies using npm
RUN npm install --omit=dev

# Copy the rest of your code
COPY . .

# Start the server
CMD ["npm", "start"]
