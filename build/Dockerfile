FROM node:16-alpine

ARG collectionFile
ARG srcDir=src

COPY $srcDir/package*.json ./
RUN npm install --production --silent

WORKDIR /runner
COPY $srcDir/*.js ./

COPY ${collectionFile} ./collection.json

CMD [ "node", "server.js" ]
