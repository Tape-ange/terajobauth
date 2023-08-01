FROM node:16.20.0-alpine as builder

ENV NODE_ENV build

USER node
WORKDIR /home/node

COPY package.json package.json
COPY yarn.lock yarn.lock

RUN yarn install \
    --prefer-offline \
    --frozen-lockfile \
    --non-interactive \
    --production=false \
    --ignore-script

COPY --chown=node:node . .
RUN yarn build

RUN rm -rf node_modules && \
    NODE_ENV=production yarn install \
    --prefer-offline \
    --pure-lockfile \
    --non-interactive \
    --production=true

# ---

FROM node:16.20.0-alpine

ENV NODE_ENV production

USER node
WORKDIR /home/node

COPY --from=builder --chown=node:node /home/node/package*.json ./
COPY --from=builder --chown=node:node /home/node/node_modules/ ./node_modules/
COPY --from=builder --chown=node:node /home/node/dist/ ./dist/

ENV HOST 0.0.0.0
EXPOSE 80

CMD ["node", "dist/main.js"]