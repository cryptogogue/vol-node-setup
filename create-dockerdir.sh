#!/bin/bash

SCRIPT_HOME="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

if [[ -z "${DOCKERDIR}" ]]; then
    echo "DOCKERDIR is undefined; default '/mnt/data/docker' will be used."
    DOCKERDIR=/mnt/data/docker
fi

if [ -d ${DOCKERDIR} ]; then
    echo "DOCKERDIR already exists; please remove or rename it."
    exit 1
fi

pushd ${SCRIPT_HOME}
    mkdir -p $DOCKERDIR/{traefik2/{acme,rules},volition}
    touch $DOCKERDIR/traefik2/acme/acme.json
    chmod 600 $DOCKERDIR/traefik2/acme/acme.json
    touch $DOCKERDIR/traefik2/traefik.log
    cp $SCRIPT_HOME/traefik2/rules/* $DOCKERDIR/traefik2/rules/
    cp $SCRIPT_HOME/.env.example $DOCKERDIR/.env
    cp $SCRIPT_HOME/docker-compose.yml $DOCKERDIR/docker-compose.yml
    cp $SCRIPT_HOME/volition.ini.example $DOCKERDIR/volition/volition.ini
popd
