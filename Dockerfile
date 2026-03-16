FROM public.ecr.aws/docker/library/node:20 AS assets-builder
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci
COPY webpack.config.js ./
COPY app/javascript ./app/javascript
RUN NODE_ENV=production npm run webpack

FROM public.ecr.aws/docker/library/ruby:3.4.9-slim-trixie
RUN apt-get update -qq && apt-get install -y build-essential libyaml-dev libpq-dev default-libmysqlclient-dev

COPY Gemfile Gemfile.lock /tmp/
RUN cd /tmp && \
  bundle config deployment 'true' && \
  bundle config path '/gems' && \
  bundle config without 'test' && \
  bundle install

WORKDIR /app
COPY . ./

COPY --from=assets-builder /app/public/packs ./public/packs

CMD ["./bin/docker_start.sh"]
