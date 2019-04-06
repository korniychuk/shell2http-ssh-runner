#!/usr/bin/env bash

set -euo pipefail

declare -r ROOT_DIR='/code'

function joinBy {
    local d=$1;
    shift;

    echo -n "$1";
    shift;

    printf "%s" "${@/#/$d}";
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

#
# Example:
#
#   if ! checkBashVersion 4 3; then
#     echo 'Minimal supported bash version 4.3' >&2
#     exit 1
#   fi
#
function checkBashVersion() {
    local -r MAJOR="${1:-0}"
    local -r MINOR="${2:-0}"
    local -r FIX="${3:-0}"

    if [[ $MAJOR -le 0 ]]; then
        echo 'checkBashVersion: Error: MAJOR version should be specified'
    fi

    if       [[ ${BASH_VERSINFO[0]} -gt ${MAJOR} ]] \
        || ( [[ ${BASH_VERSINFO[0]} -eq ${MAJOR} ]] && [[ ${BASH_VERSINFO[1]} -gt ${MINOR} ]] ) \
        || ( [[ ${BASH_VERSINFO[0]} -eq ${MAJOR} ]] && [[ ${BASH_VERSINFO[1]} -eq ${MINOR} ]] && [[ ${BASH_VERSINFO[2]} -ge ${FIX} ]] )
    then
       return 0
    else
       return 1
    fi
}

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

function readUrlsFile() {
    local -r fileName="${1}"
    local -n arrLink="${2}"
    arrLink=()

    while IFS='=' read -r url command; do
      local safeCommand=$(echo "${command}" | base64 -- | tr -d '\n')
      arrLink+=("${url}" "${ROOT_DIR}/ssh-runner.sh ${safeCommand}")
    done < "${ROOT_DIR}/${fileName}"
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
    declare -a ARGS
    readUrlsFile "${RUNNER_URLS_FILE}" ARGS
    shell2http -export-vars="$(joinBy ',' "${VARS[@]}")" "${ARGS[@]}"

    exit 0
fi

if [[ -z ${TARGET_URL+x} ]]; then
    TARGET_URL="POST:/"
fi

shell2http -export-vars="$(joinBy ',' "${VARS[@]}")" "${TARGET_URL}" "${ROOT_DIR}/ssh-runner.sh"
