FROM ruby:2.6.2-slim-stretch
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev default-libmysqlclient-dev nodejs-legacy curl git
RUN curl -sL https://deb.nodesource.com/setup_11.x | bash -
RUN apt-get -y install nodejs
RUN mkdir /app

ADD Gemfile /tmp/Gemfile
ADD Gemfile.lock /tmp/Gemfile.lock
RUN cd /tmp && bundle install -j5 --deployment --without test

ADD vendor/assets/package.json /tmp/vendor/assets/package.json
RUN cd /tmp/vendor/assets && npm install && rm -rf node_modules/jquery

WORKDIR /app
RUN mv /tmp/vendor /app
ADD . /app

# Avoid Missing `secret_key_base` Error
RUN SECRET_KEY_BASE=dummy \
    bundle exec rake assets:precompile RAILS_ENV=production

CMD ["./bin/docker_start.sh"]
