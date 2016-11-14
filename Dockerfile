FROM ruby:2.3.1-alpine
ENV RAILS_ENV=production
RUN apk add --no-cache --update tzdata && \
    apk add --no-cache --virtual build-dependencies \
    build-base \
    libxml2-dev \
    libxslt-dev
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
WORKDIR /app
RUN bundle install --without test development && apk del build-dependencies
COPY . /app
CMD ["bundle", "exec", "rails", "server"]
ARG REVISION
LABEL revision=$REVISION maintainer="Nee-co"
