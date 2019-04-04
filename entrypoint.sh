#!/usr/bin/env bash

set -euo pipefail

declare -r ROOT_DIR='/code'

function initSSH() {
    if [[ ! -d ~/.ssh ]]; then
        mkdir ~/.ssh
    fi

    if [[ ! -f ~/.ssh/known_hosts ]]; then
        ssh-keyscan -H ${SSH_SERVER} > ~/.ssh/known_hosts

        local -r IP=$(dig +search +short ${SSH_SERVER})
        if [[ "$IP" != "" ]]; then
            ssh-keyscan -H "${IP}" >> ~/.ssh/known_hosts
        fi
    fi
}

function joinBy {
    local d=$1;
    shift;

    echo -n "$1";
    shift;

    printf "%s" "${@/#/$d}";
}

function readUrlsFile() {
    local -r FILE_NAME="${1}"
    local -a res=()

    while IFS='=' read -r url command; do
        safeUrl=$(echo "${url}" | sed -e 's/"/\\"/g')

        escapedCommand=$(echo "${command}" | sed -e 's/"/\\\\"/g')
        safeCommand="bash -c \\\"${escapedCommand}\\\""

        res+=("\"${safeUrl}\"" "\"${safeCommand}\"")
    done < "${ROOT_DIR}/${FILE_NAME}"

    echo "${res[@]}"
}

function inArray() {
    local needle="${1}"; shift
    local haystack="${@}"

    for haystack; do
        if [[ "$haystack" == "$needle" ]]; then
            return 0;
        fi
    done

    return 1;
}

declare -a VARS=(
    SSH_USERNAME
    SSH_SERVER
    REMOTE_SCRIPT_FILENAME
    REMOTE_COMMAND
    RUNNER_MODE
)

declare -a AVAILABLE_MODES=(
    'command'
    'script-file'
    'urls-file-with-commands'
)

if ! inArray "${RUNNER_MODE}" "${AVAILABLE_MODES[@]}"; then
    echo "Incorrect RUNNER_MODE: '${RUNNER_MODE}'. Available modes: ${AVAILABLE_MODES[@]}" >&2
    edit 1
fi

initSSH

if [[ "$RUNNER_MODE" == 'urls-file-with-commands' ]]; then
    shell2http -export-vars="$(joinBy ',' "${VARS[@]}")" \
        "POST:/" "cd ~ && ls -la" \
        "POST:/go" 'echo "hello !" && cd ~/"Test Multiword Dir" && pwd && ls -laH' \
        "POST:/date" "echo \"super duper\"" \
        "POST:/super" "echo gen me to po so"
#    shell2http -export-vars="$(joinBy ',' "${VARS[@]}")" $(readUrlsFile "${RUNNER_URLS_FILE}")
#    eval "shell2http -export-vars=\"$(joinBy ',' "${VARS[@]}")\" $(readUrlsFile "${RUNNER_URLS_FILE}")"
#    echo "shell2http -export-vars=\"$(joinBy ',' "${VARS[@]}")\" $(readUrlsFile "${RUNNER_URLS_FILE}")"
    exit 0
fi

if [[ -z ${TARGET_URL+x} ]]; then
    TARGET_URL="POST:/"
fi

shell2http -export-vars="$(joinBy ',' "${VARS[@]}")" "${TARGET_URL}" /code/ssh-runner.sh

закончил на том что какая-то ебаная борода с этим скриптом
