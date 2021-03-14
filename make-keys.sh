#!/bin/bash

SCRIPT_HOME="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

source ${SCRIPT_HOME}/.env

KEYS_FOLDER="$1"

if [[ -z "${KEYS_FOLDER}" ]]; then

    if [[ -z "${DOCKERDIR}" ]]; then
        echo "DOCKERDIR is undefined; default '/mnt/data/docker' will be used."
        DOCKERDIR=/mnt/data/docker
    fi

    KEYS_FOLDER=$DOCKERDIR/volition/keys
fi

if [ -d ${KEYS_FOLDER} ]; then
	echo "Keys folder already exists; please remove or rename it."
	exit 1
fi

mkdir -p ${KEYS_FOLDER}

pushd ${KEYS_FOLDER}

    openssl genrsa -out mining.priv.pem 4096
    openssl rsa -in mining.priv.pem -outform PEM -pubout -out mining.pub.pem

    openssl ecparam -genkey -name secp256k1 -conv_form compressed -noout -out control.priv.pem.tmp
    openssl pkcs8 -in control.priv.pem.tmp -topk8 -nocrypt -out control.priv.pem
    openssl ec -in control.priv.pem -outform PEM -pubout -out control.pub.pem
    rm control.priv.pem.tmp

popd
