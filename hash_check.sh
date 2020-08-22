#!/bin/bash

set -u > /dev/null
# set -e > /dev/null
set -o > /dev/null
# set -x

# BASE_URL="https://tiup-mirrors.pingcap.com/pd-v4.0.2-linux-amd64.tar.gz"
BASE_URL="https://tiup-mirrors.pingcap.com"
# BASE_URL="https://download.pingcap.org"

check_hash() {
    local url=$1
    local hash_sum=$2
    local ver=$3
    
    local version

    curl -sL -o pack.tar $url
    mkdir -p packdir && tar xzf pack.tar -C packdir
    cd packdir

    if [[ `uname` =~ "Darwin" ]]; then
        binpath=`find . -perm +111 -type f | xargs file | grep 'Mach-O 64-bit executable x86_64' | cut -d':' -f1`
    else
        binpath=`find -type f -executable -exec file -i '{}' \; | grep 'x-executable; charset=binary' | cut -d':' -f1`
    fi

    for bin in ${binpath[@]}; do
        version=`$bin -V || $bin version || $bin --version`
        if [[ ! $version =~ $hash_sum ]]
        then
            echo "$url $binpath wrong hash ----------"
        fi
        
        if [[ ! $version =~ $ver ]]
        then
            echo "$url $binpath wrong version -------- "
        fi
    done

    echo "DONE checking $url $binpath"
    cd ..
    rm -r packdir
}


main() {
    local hash_file_url=$1
    local version=$2
    local platform=$3

    local result=""
    local url

    curl -sL -o hash.json '$hash_file_url'
    hashes=( $(./extract.py hash.json) )
    length=${#hashes[@]}    

    mkdir -p release_version_check
    cd release_version_check

    for ((i=0 ; i<$length; i=$i+2 )); do 
        comp=${hashes[$i]}
        hash_sum=${hashes[$i+1]}
        url=$BASE_URL/$comp-$version-$platform.tar.gz

        check_hash $url $hash_sum $version
        result="`check_hash $url $hash_sum $version` $result"
    done
    
    cd ..
    rm -r release_version_check
    echo $result
}

if [[ ! $# -eq 3 ]]; then
    echo "usage: hash_check.sh <hash_file_url> <version> <platform>"
    echo "example: hash_check.sh http://127.0.0.1/hash.json v4.0.2 linux-amd64"
    exit 1
fi

main $@
