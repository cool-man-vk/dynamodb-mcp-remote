# Production stage
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
COPY src/* ./
COPY tsconfig.json ./

# Install production dependencies only
RUN npm install --force
RUN npm run build

# Copy built application from builder stage
COPY --from=builder --chown=nodejs:nodejs /app/dist ./dist
COPY --from=builder --chown=nodejs:nodejs /app/node_modules ./node_modules

# Copy configuration files
COPY --chown=nodejs:nodejs smithery.json* ./

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