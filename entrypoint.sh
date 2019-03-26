#!/usr/bin/env sh

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

VARS=\
SSH_USERNAME\
,SSH_SERVER\
,REMOTE_SCRIPT_FILENAME\
,REMOTE_COMMAND\
,RUNNER_MODE

shell2http -export-vars=${VARS} / /code/ssh-runner.sh
