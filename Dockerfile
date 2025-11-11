FROM node:22.12-alpine as builder

COPY . /app
COPY tsconfig.json /tsconfig.json

WORKDIR /app

RUN --mount=type=cache,target=/root/.npm npm install

RUN --mount=type=cache,target=/root/.npm-production npm ci --ignore-scripts --omit-dev

FROM node:22-alpine AS release

COPY --from=builder /app/dist /app/dist
COPY --from=builder /app/package.json /app/package.json
COPY --from=builder /app/package-lock.json /app/package-lock.json

ENV NODE_ENV=production
ENV MCP_HOST=0.0.0.0
ENV MCP_PORT=3000

WORKDIR /app

RUN npm ci --ignore-scripts --omit-dev

EXPOSE 3000

ENTRYPOINT ["node", "dist/index.js"]
