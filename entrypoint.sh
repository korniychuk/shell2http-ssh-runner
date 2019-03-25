#!/usr/bin/env sh

if [[ ! -d ~/.ssh ]]; then
    mkdir ~/.ssh
fi

ssh-keyscan -H ${SSH_SERVER} > ~/.ssh/known_hosts
shell2http -export-vars=SSH_USERNAME,SSH_SERVER,REMOTE_SCRIPT_FILENAME,REMOTE_COMMAND / /code/ssh-runner.sh
