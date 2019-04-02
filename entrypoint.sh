#!/usr/bin/env bash

#echo "${RUNNER_COMMANDS}" | tr ';' '\n' | while IFS=: read -r url command; do
#    echo "'${url}::${command}'"
#done

while IFS='=' read -r url command; do
    declare safeUrl="\"${url//\"/\\\"}\""
#    declare -r safeCommand="bash -c \"/code/ssh-runner.sh \\\"${command//\"/\\\"}\\\"\""
    declare safeCommand="bash -c \"echo \\\"${command//\"/\\\"}\\\"\""
#    echo "\"${url//\"/\\\"}\"" "bash -c \"/code/ssh-runner.sh \\\"${command//\"/\\\"}\\\"\""
    echo $safeUrl :: $safeCommand
    eval $safeCommand
done < "/code/$RUNNER_URLS_FILE"


#bash --version

#arr=( $(echo "${RUNNER_COMMANDS}" | tr ";;" "\n") )
##IFS=";;", read -r -a arr <<< "${RUNNER_COMMANDS}"
##
#echo "'${arr[0]}'"
#echo "'${arr[1]}'"
#echo "'${arr[2]}'"
#RUNNER_COMMANDS="
#    /:some;;
#    /date:cd ~ && ls -laH && docker-compose --version;;
#    /super: echo gen me to po so;;
#"
#
#echo -e $RUNNER_COMMANDS

exit

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

#/=so":"m:e
#/date=cd ~ && ls -laH && docker-compose --version
#/super=echo gen me to po so
