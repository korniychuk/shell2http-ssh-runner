#!/usr/bin/env bash

function readCommands() {
    local -r FILE_NAME="${1}"
    local -a res=()

    while IFS='=' read -r url command; do
        safeUrl=$(echo "${url}" | sed -e 's/"/\\"/g')

        escapedCommand=$(echo "${command}" | sed -e 's/"/\\\\"/g')
        safeCommand="bash -c \\\"${escapedCommand}\\\""

        res+=("\"${safeUrl}\"" "\"${safeCommand}\"")
    done < "./${FILE_NAME}"
    echo "${res[@]}"
}

#echo "${res[0]}"
#echo "${res[1]}"
#echo "${res[2]}"
#echo "${res[3]}"
#echo "${res[4]}"
#echo "${res[5]}"

#echo "${res[@]}"

declare arr=$(readCommands 'test-urls.cfg')
echo "${arr}"

#res=""
#
#command='echo "hello !" && cd ~/"MEGAsync Downloads" && pwd && ls -laH'
#escapedCommand=$(echo "${command}" | sed -e 's/"/\\\\"/g')
#fullCommand="bash -c \\\"${escapedCommand}\\\""
#res="${res} \"${fullCommand}\""
##eval "${safeCommand}"
#echo $res
#
##echo $a | sed -e 's/"/\\"/g'
