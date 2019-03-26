#!/usr/bin/env sh

if [[ ! -d ~/.ssh ]]; then
    mkdir ~/.ssh
fi

if [[ ! -f ~/.ssh/known_hosts ]]; then
    ssh-keyscan -H ${SSH_SERVER} > ~/.ssh/known_hosts
fi

shell2http -export-vars=SSH_USERNAME,SSH_SERVER,REMOTE_SCRIPT_FILENAME,REMOTE_COMMAND / /code/ssh-runner.sh
