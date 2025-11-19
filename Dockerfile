FROM node:20-alpine

# Install required packages
RUN apk add --no-cache dumb-init curl

# Set working directory
WORKDIR /app

# Copy everything
COPY . .

# Install dependencies and build
RUN npm install && \
    npm run build && \
    npm prune --production

# Set environment
ENV NODE_ENV=production \
    PORT=8080

# Expose port
EXPOSE 8080

# Start the application
ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "dist/index.js"]