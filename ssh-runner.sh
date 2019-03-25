#!/usr/bin/env sh

set -euo pipefail

if [[ -z ${REMOTE_SCRIPT_FILENAME+x} ]] || [[ "${REMOTE_SCRIPT_FILENAME}" == "" ]]; then
    REMOTE_SCRIPT_FILENAME='remote-hello.sh'
fi

if [[ -z ${RUNNER_MODE+x} ]] || [[ "${RUNNER_MODE}" == "" ]]; then
    RUNNER_MODE='script-file'
fi

CODE_DIR=/code
SSH_KEY="$CODE_DIR/ssh.key"
REMOTE_SCRIPT="$CODE_DIR/$REMOTE_SCRIPT_FILENAME"

if [[ ! -f "$SSH_KEY" ]]; then
    echo "SSH Private Key not provided at '$SSH_KEY'" >&2
    exit 1
fi

if [[ "${RUNNER_MODE}" == 'script-file' ]]; then
    if [[ ! -f "$REMOTE_SCRIPT_FILENAME" ]]; then
        echo "Can not find script file '${REMOTE_SCRIPT}'" >&2
        exit 3
    fi

    ssh -i "$SSH_KEY" "${SSH_USERNAME}@${SSH_SERVER}" < "$REMOTE_SCRIPT"

elif [[ "${RUNNER_MODE}" == 'command' ]]; then

    if [[ -z ${REMOTE_COMMAND+x} ]]; then
        echo "REMOTE_COMMAND variable is not exists" >&2
        exit 4
    fi

    ssh -i "$SSH_KEY" "${SSH_USERNAME}@${SSH_SERVER}" "$REMOTE_COMMAND"

else
    echo "Wrong RUNNER_MODE: '${RUNNER_MODE}'" >&2
    exit 2
fi

