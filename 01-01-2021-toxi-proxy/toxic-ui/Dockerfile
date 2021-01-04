FROM node:14.15.3-alpine

RUN mkdir app
WORKDIR /app
COPY ./package.json .
RUN yarn install
CMD yarn start