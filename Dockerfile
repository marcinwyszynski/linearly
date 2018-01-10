FROM ruby:2.5.0-alpine
RUN apk add --no-cache git

ADD . /linearly
WORKDIR /linearly
RUN bundle install --jobs 8 --retry 5
