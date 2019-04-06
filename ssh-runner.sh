#!/usr/bin/env bash

set -euo pipefail

function joinBy {
    local d=$1;
    shift;

    echo -n "$1";
    shift;

    printf "%s" "${@/#/$d}";
}

if [[ -z ${RUNNER_MODE+x} ]] || [[ "${RUNNER_MODE}" == "" ]]; then
    RUNNER_MODE='script-file'
fi

declare -r CODE_DIR="/code"
declare -r SSH_KEY="$CODE_DIR/ssh.key"

if [[ ! -f "$SSH_KEY" ]]; then
    echo "SSH Private Key not provided at '$SSH_KEY'" >&2
    exit 1
fi

if [[ "${RUNNER_MODE}" == 'script-file' ]]; then

    if [[ -z ${REMOTE_SCRIPT_FILENAME+x} ]] || [[ "${REMOTE_SCRIPT_FILENAME}" == "" ]]; then
        REMOTE_SCRIPT_FILENAME='remote-hello.sh'
    fi

    declare -r REMOTE_SCRIPT="$CODE_DIR/$REMOTE_SCRIPT_FILENAME"

    if [[ ! -f "${REMOTE_SCRIPT}" ]]; then
        echo "Can not find script file '${REMOTE_SCRIPT}'" >&2
        exit 3
    fi

    ssh -T -i "$SSH_KEY" "${SSH_USERNAME}@${SSH_SERVER}" < "$REMOTE_SCRIPT"

elif [[ "${RUNNER_MODE}" == 'command' ]]; then

    if [[ -z ${REMOTE_COMMAND+x} ]]; then
        echo "REMOTE_COMMAND variable is not exists" >&2
        exit 4
    fi

    ssh -T -i "$SSH_KEY" "${SSH_USERNAME}@${SSH_SERVER}" "$REMOTE_COMMAND"

elif [[ "${RUNNER_MODE}" == 'urls-file-with-commands' ]]; then
    declare -r safeCommand="${1}"
    declare -r command=$(echo "${safeCommand}" | base64 -d --)

    ssh -T -i "$SSH_KEY" "${SSH_USERNAME}@${SSH_SERVER}" "${command}"
else
    echo "Wrong RUNNER_MODE: '${RUNNER_MODE}'" >&2
    exit 2
fi
