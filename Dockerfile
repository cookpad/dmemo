FROM ruby:2.3.1-slim
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev libmysqlclient-dev nodejs
RUN mkdir /app
WORKDIR /app
ADD Gemfile /app/Gemfile
ADD Gemfile.lock /app/Gemfile.lock
RUN bundle install -j 5 --without development test && ./bin/rake assets:precompile RAILS_ENV=production
ADD . /app
