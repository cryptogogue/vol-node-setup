#!/bin/bash

if [[ -z "${DOCKERDIR}" ]]; then
    echo "DOCKERDIR is undefined; default '/mnt/data/docker' will be used."
    DOCKERDIR=/mnt/data/docker
fi

pushd ${SCRIPT_HOME}
    docker-compose down
popd
