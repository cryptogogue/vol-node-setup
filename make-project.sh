#!/bin/bash

SCRIPT_HOME="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

USE_CLOUDFLARE=0

while getopts ":c" flag
do
    case "${flag}" in
        c) USE_CLOUDFLARE=1;;
    esac
done
shift $((OPTIND -1))

DOCKERDIR=$1

if [[ -z "${DOCKERDIR}" ]]; then
    echo "DOCKERDIR is undefined; default '/mnt/data/docker' will be used."
    DOCKERDIR=/mnt/data/docker
fi

if [ -d ${DOCKERDIR} ]; then
    echo "DOCKERDIR already exists; please remove or rename it."
    exit 1
fi

echo $DOCKERDIR
echo $USE_CLOUDFLARE

pushd ${SCRIPT_HOME}
    mkdir -p $DOCKERDIR/{traefik2/{acme,rules},volition}
    touch $DOCKERDIR/traefik2/acme/acme.json
    chmod 600 $DOCKERDIR/traefik2/acme/acme.json
    touch $DOCKERDIR/traefik2/traefik.log

    cp $SCRIPT_HOME/support/traefik2/rules/* $DOCKERDIR/traefik2/rules/
    cp $SCRIPT_HOME/support/docker-compose.yml $DOCKERDIR/docker-compose.yml
    cp $SCRIPT_HOME/support/volition.ini.example $DOCKERDIR/volition/volition.ini

    cp $SCRIPT_HOME/support/down.sh $DOCKERDIR/down.sh
    cp $SCRIPT_HOME/support/up.sh $DOCKERDIR/up.sh
    cp $SCRIPT_HOME/support/make-keys.sh $DOCKERDIR/make-keys.sh
    cp $SCRIPT_HOME/support/make-networks.sh $DOCKERDIR/make-networks.sh

    if [ "${USE_CLOUDFLARE}" ]; then
        cp $SCRIPT_HOME/support/docker-compose.cloudflare.yml $DOCKERDIR/docker-compose.override.yml
        cp $SCRIPT_HOME/support/.env.cloudflare.example $DOCKERDIR/.env
    else
        cp $SCRIPT_HOME/support/docker-compose.letsencrypt.yml $DOCKERDIR/docker-compose.override.yml
        cp $SCRIPT_HOME/support/.env.letsencrypt.example $DOCKERDIR/.env
    fi
popd
