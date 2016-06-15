FROM ruby:2.3.1-slim
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev libmysqlclient-dev nodejs nodejs-legacy npm git
RUN npm install -g bower
RUN mkdir /app

ADD Gemfile /tmp/Gemfile
ADD Gemfile.lock /tmp/Gemfile.lock
RUN cd /tmp && bundle install -j5 --deployment --without test

ADD vendor/assets/bower.json /tmp/vendor/assets/bower.json
ADD vendor/assets/.bowerrc /tmp/vendor/assets/.bowerrc
RUN cd /tmp/vendor/assets && bower install -p --allow-root

WORKDIR /app
RUN mv /tmp/vendor /app
ADD . /app
RUN bundle exec rake assets:precompile RAILS_ENV=production

CMD ["./bin/docker_start.sh"]
