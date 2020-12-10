FROM ruby:2.3.0-slim

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs postgresql

RUN mkdir /application

COPY . /application

WORKDIR /application

RUN bundle install

EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]
