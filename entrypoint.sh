#!/usr/bin/env sh

set -euo pipefail

if [[ ! -d ~/.ssh ]]; then
    mkdir ~/.ssh
fi

if [[ ! -f ~/.ssh/known_hosts ]]; then
    ssh-keyscan -H ${SSH_SERVER} > ~/.ssh/known_hosts

    IP=$(dig +search +short ${SSH_SERVER})
    if [[ "$IP" != "" ]]; then
        ssh-keyscan -H "${IP}" >> ~/.ssh/known_hosts
    fi
fi

if [[ -z ${TARGET_URL+x} ]]; then
    TARGET_URL="POST:/"
fi

VARS=\
SSH_USERNAME\
,SSH_SERVER\
,REMOTE_SCRIPT_FILENAME\
,REMOTE_COMMAND\
,RUNNER_MODE

shell2http -export-vars=${VARS} "${TARGET_URL}" /code/ssh-runner.sh
