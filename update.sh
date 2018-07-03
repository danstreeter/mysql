#!/bin/bash

function makeVersion {
    export SOURCE_MYSQL_VERSION="$1"
    envsubst < Dockerfile_template > "${1}/Dockerfile"
    cp docker-entrypoint.sh "${1}/flowmoco-init.sh"
    chmod a+x "${1}/flowmoco-init.sh"
}

makeVersion "8.0"
makeVersion "5.5"
makeVersion "5.6"
makeVersion "5.7"

