# ========== BUILD STAGE ==========
FROM node:20-alpine AS builder

# Add build arguments
ARG NODE_ENV=production

# Install build dependencies (needed for some npm packages)
RUN apk add --no-cache python3 make g++

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install all dependencies (including devDependencies for building)
RUN npm install --force

# Copy source code and configuration files
COPY tsconfig.json ./
COPY src ./src
COPY smithery.json* ./

# Build the TypeScript application
RUN npm run build

# ========== PRODUCTION STAGE ==========
FROM node:20-alpine

# Install runtime dependencies
RUN apk add --no-cache \
    dumb-init \
    curl \
    && rm -rf /var/cache/apk/*

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install production dependencies only
RUN npm install --production --force

# Copy built application from builder stage
COPY --from=builder --chown=nodejs:nodejs /app/dist ./dist

# Copy source files (in case they're needed at runtime)
COPY --from=builder --chown=nodejs:nodejs /app/src ./src

# Copy configuration files
COPY --from=builder --chown=nodejs:nodejs /app/smithery.json* ./
COPY --from=builder --chown=nodejs:nodejs /app/tsconfig.json* ./

# Create temp directory for the app
RUN mkdir -p /app/tmp && chown -R nodejs:nodejs /app/tmp

# Switch to non-root user
USER nodejs

# Set environment variables
ENV NODE_ENV=production \
    PORT=8080 \
    NODE_OPTIONS="--max-old-space-size=512"

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8080/health || exit 1

# Use dumb-init to handle signals properly
ENTRYPOINT ["dumb-init", "--"]

# Start the application
CMD ["node", "dist/index.js"]