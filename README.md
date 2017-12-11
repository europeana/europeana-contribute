# Europeana Stories

[![Build Status](https://travis-ci.org/europeana/europeana-stories.svg?branch=develop)](https://travis-ci.org/europeana/europeana-stories) [![Coverage Status](https://coveralls.io/repos/github/europeana/europeana-stories/badge.svg?branch=develop)](https://coveralls.io/github/europeana/europeana-stories?branch=develop) [![security](https://hakiri.io/github/europeana/europeana-stories/develop.svg)](https://hakiri.io/github/europeana/europeana-stories/develop) [![Dependency Status](https://gemnasium.com/europeana/europeana-stories.svg)](https://gemnasium.com/europeana/europeana-stories)

Europeana Stories is a storytelling platform enabling members of the public
to contribute their stories about European cultural heritage to
[Europeana](https://www.europeana.eu/).


## Requirements

* Ruby 2.4.2 & Bundler
* MongoDB
* S3 object storage


## Getting started

For non-production environments, you may use the supplied Docker configuration
to get started:

```shell
bundle exec ./docker/setup
docker-compose up
```

Docker will now be running two containers:
* `minio` for S3 object storage at `localhost:3001`, including a web UI at
  http://localhost:3001/
* `mongodb` for metadata storage at `localhost:3002`

Your S3 access and secret keys along with other S3 configuration will have been
written to the files `.env.development` and `.env.test`. Uploaded files will
be stored in `tmp/minio`.

Install the gem bundle:
```shell
bundle install
```

Seed MongoDB with license data:
```shell
bundle exec rake db:seed
```

Start the web server:
```shell
bundle exec rails s
```

Now Europeana Stories will be accessible at http://localhost:3000/ and its
admin interface at http://localhost:3000/admin


## License

Licensed under the EUPL V.1.1.

For full details, see [LICENSE.md](LICENSE.md).
