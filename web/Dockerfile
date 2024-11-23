# Use official node.js runtime as a base image
FROM node:16-alpine

# Set working directory inside container
WORKDIR /app

# Copy package.json and package-lock.json first to leverage Docker cache efficiently
COPY package.json /app/
COPY package-lock.json /app/

# Install dependencies using npm
RUN npm install

# Copy the rest of the application code
COPY . /app

# Expose the port the app runs on
EXPOSE 8080

# Define the command to run your app
CMD ["npm", "start"]

