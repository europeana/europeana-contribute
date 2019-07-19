# Europeana Contribute

[![Build Status](https://travis-ci.org/europeana/europeana-contribute.svg?branch=master)](https://travis-ci.org/europeana/europeana-contribute) [![Security](https://hakiri.io/github/europeana/europeana-contribute/master.svg)](https://hakiri.io/github/europeana/europeana-contribute/master) [![Maintainability](https://api.codeclimate.com/v1/badges/6516bf2d4ea3287da25d/maintainability)](https://codeclimate.com/github/europeana/europeana-contribute/maintainability) [![Test Coverage](https://api.codeclimate.com/v1/badges/6516bf2d4ea3287da25d/test_coverage)](https://codeclimate.com/github/europeana/europeana-contribute/test_coverage)

Europeana Contribute is a contribution platform enabling members of the public
to share their European cultural heritage with [Europeana](https://www.europeana.eu/).


## Requirements

* Ruby 2.5.5 & Bundler
* MongoDB
* Redis
* S3 object storage


## Getting started

For non-production environments, you may use the supplied Docker configuration
to get started:

```shell
bundle exec ./docker/setup
docker-compose up
```

Docker will now be running three containers:
* `minio` for S3 object storage at `localhost:3001`, including a web UI at
  http://localhost:3001/
* `mongodb` for metadata storage at `localhost:3002`
* `redis` for enqueuing sidekiq jobs at `localhost:3003`

Your S3 access and secret keys along with other S3 configuration will have been
written to the files `.env.development` and `.env.test`. Uploaded files will
be stored in `tmp/minio`.

Install the gem bundle:
```shell
bundle install
```

Create MongoDB indexes, and seed:
```shell
bundle exec rake db:mongoid:create_indexes
bundle exec rake db:seed
```

Create an admin user:
```
bundle exec rake user:create EMAIL=your.name@example.org PASSWORD=secret
```

Start the web server and a sidekiq instance using foreman:
```shell
bundle exec foreman start
```

Now Europeana Contribute will be accessible at http://localhost:5000/ and its
admin interface at http://localhost:5000/users and http://localhost:5000/contributions

If no other port is specified, port 5000 is set as the default by foreman
initialization. To change the port simply add another PORT to your .env file.

```
#.env
PORT=3000
```


## reCAPTCHA

In order to prevent bots from submitting content through the UGC application,
anonymous users will be required to prove they are not robots using the reCAPTCHA tool.
To enable this functionality you need to set ENV variables for the relevant [keys](https://www.google.com/recaptcha/admin)

* RECAPTCHA_SITE_KEY
* RECAPTCHA_SECRET_KEY


## Testing

System tests use Firefox in headless mode.


## License

Licensed under the EUPL v1.2.

For full details, see [LICENSE.md](LICENSE.md).
