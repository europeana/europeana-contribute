FROM ruby:2.5-buster

ENV RAILS_ENV=production \
    BUNDLER_VERSION=2.1.4

WORKDIR /app

# RUN apk add --no-cache git build-base tzdata
RUN gem install bundler -v ${BUNDLER_VERSION}
RUN bundle config set without 'development test'

COPY Gemfile ./

RUN bundle install

COPY . .

RUN SECRET_KEY_BASE="x" bundle exec rake assets:precompile

CMD ["bundle", "exec", "rails", "s"]
