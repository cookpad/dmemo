FROM ruby:2.3.1-slim
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev libmysqlclient-dev nodejs nodejs-legacy npm git
RUN mkdir /app

ADD Gemfile /tmp/Gemfile
ADD Gemfile.lock /tmp/Gemfile.lock
RUN cd /tmp && bundle install -j5 --deployment --without test

ADD vendor/assets/package.json /tmp/vendor/assets/package.json
RUN cd /tmp/vendor/assets && npm install && rm -rf node_modules/jquery

WORKDIR /app
RUN mv /tmp/vendor /app
ADD . /app
RUN bundle exec rake assets:precompile RAILS_ENV=production

CMD ["./bin/docker_start.sh"]
