#! /bin/bash

CURRENT_DIR="$(dirname "$0")"

pushd "$CURRENT_DIR"

curl -i -X PUT -H "Accept:application/json" -H  "Content-Type:application/json" \
 http://localhost:8083/connectors/pg-connector/config -d @../connectors/genesis-source.json

# curl -i -X PUT -H "Accept:application/json" -H  "Content-Type:application/json" \
#  http://localhost:8083/connectors/genesis-s3-sink-connector/config -d @../connectors/genesis-s3-sink.json

popd