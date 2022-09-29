FROM ruby:2.5.5-alpine

ENV RAILS_ENV=production \
    BUNDLER_VERSION=2.1.4

RUN apk add --update \
  tzdata \
  nodejs \
  build-base \
  git

RUN gem install bundler -v ${BUNDLER_VERSION}

RUN apk add --update \
  build-base \
  git

WORKDIR /app

COPY Gemfile Gemfile.lock ./

RUN bundle config set without "development test" && \
  bundle install --jobs=3 --retry=3

RUN apk del \
  build-base \
  git

COPY . ./

RUN SECRET_KEY_BASE=assets bundle exec rake assets:precompile

CMD ["bundle", "exec", "rails", "s"]
