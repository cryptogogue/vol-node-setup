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

PROJECTDIR=$1

if [[ -z "$PROJECTDIR" ]]; then
    echo "PROJECTDIR is undefined; default '/mnt/data/docker' will be used."
    PROJECTDIR=/mnt/data/docker
fi

if [ -d "$PROJECTDIR" ]; then
    echo "PROJECTDIR already exists; please remove or rename it."
    exit 1
fi

pushd ${SCRIPT_HOME}
    mkdir -p $PROJECTDIR/{traefik2/{acme,rules},volition}
    touch $PROJECTDIR/traefik2/acme/acme.json
    chmod 600 $PROJECTDIR/traefik2/acme/acme.json
    touch $PROJECTDIR/traefik2/traefik.log

    cp $SCRIPT_HOME/support/traefik2/rules/* $PROJECTDIR/traefik2/rules/
    cp $SCRIPT_HOME/support/compose-traefik/docker-compose.yml $PROJECTDIR/docker-compose.yml
    cp $SCRIPT_HOME/support/volition.ini.example $PROJECTDIR/volition/volition.ini

    cp $SCRIPT_HOME/support/down.sh $PROJECTDIR/down.sh
    cp $SCRIPT_HOME/support/up.sh $PROJECTDIR/up.sh
    cp $SCRIPT_HOME/support/make-keys.sh $PROJECTDIR/make-keys.sh
    cp $SCRIPT_HOME/support/make-networks.sh $PROJECTDIR/make-networks.sh

    if [ "$USE_CLOUDFLARE" -eq "0" ]; then
        cp $SCRIPT_HOME/support/compose-traefik/docker-compose.letsencrypt.yml $PROJECTDIR/docker-compose.override.yml
        cp $SCRIPT_HOME/support/.env.letsencrypt.example $PROJECTDIR/.env
    else
        cp $SCRIPT_HOME/support/compose-traefik/docker-compose.cloudflare.yml $PROJECTDIR/docker-compose.override.yml
        cp $SCRIPT_HOME/support/.env.cloudflare.example $PROJECTDIR/.env
    fi
popd
