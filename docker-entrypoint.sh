#!/usr/bin/env sh

set -e

if [ "${MONGODB_SSL_CA_CERT}" != "" ]; then
  crt_filename="/app/config/mongodb-ssl-ca.crt"
  echo "Writing MongoDB SSL CA cert from env MONGODB_SSL_CA_CERT to ${crt_filename}"
  echo -e "${MONGODB_SSL_CA_CERT}\n" >> ${crt_filename}
fi

if [ "${REDIS_SSL_CA_CERT}" != "" ]; then
  crt_filename="/app/config/redis-ssl-ca.crt"
  echo "Writing Redis SSL CA cert from env REDIS_SSL_CA_CERT to ${crt_filename}"
  echo -e "${REDIS_SSL_CA_CERT}\n" >> ${crt_filename}
fi

exec "$@"
