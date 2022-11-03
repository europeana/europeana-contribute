FROM ruby:2.5.5-alpine AS base

ENV RAILS_ENV=production \
    BUNDLER_VERSION=2.1.4 \
    PORT=8080 \
    WEB_CONCURRENCY=1 \
    ELASTIC_APM_SERVICE_NAME=contribute \
    ELASTIC_APM_ENVIRONMENT=development

WORKDIR /app

RUN apk add --update \
  tzdata \
  nodejs \
  file \
  imagemagick

RUN gem install bundler -v ${BUNDLER_VERSION}


FROM base as dependencies

RUN apk add --update \
  build-base \
  git

COPY Gemfile Gemfile.lock ./

RUN bundle config set without "development test" && \
  bundle install --jobs=3 --retry=3


FROM base

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["bundle", "exec", "rails", "s"]
EXPOSE ${PORT}

COPY docker-entrypoint.sh /

COPY --from=dependencies /usr/local/bundle/ /usr/local/bundle/

COPY . ./

RUN ELASTIC_APM_ENABLED=false SECRET_KEY_BASE=assets bundle exec rake assets:precompile
