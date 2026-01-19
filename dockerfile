# build stage
FROM node:18-alpine as build-stage
WORKDIR /app

COPY package.json .
COPY pnpm-lock.yaml ./

RUN apk update
RUN apk add --no-cache git

RUN npm install -g pnpm@8.6.0

RUN pnpm install

COPY . .

# ENV
ENV DIRECTUS_URL=${DIRECTUS_URL}
ENV DIRECTUS_SERVER_TOKEN=${DIRECTUS_SERVER_TOKEN}
ENV SITE_URL=${SITE_URL}

RUN NODE_OPTIONS="--max-old-space-size=4096" pnpm build

# production stage
FROM node:18-slim as production

COPY --from=build-stage /app/.output /app/.output
COPY --from=build-stage /app/node_modules /app/node_modules

EXPOSE 3000

CMD ["node", "/app/.output/server/index.mjs"]
