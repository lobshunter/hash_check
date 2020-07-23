#!/bin/bash

set -u
set -e
set -o
# set -x

# BASE_URL="https://tiup-mirrors.pingcap.com/pd-v4.0.2-linux-amd64.tar.gz"
BASE_URL="https://tiup-mirrors.pingcap.com"

check_hash() {
    local url=$1
    local hash_sum=$2
    local ver=$3

    curl -sL -o pack.tar $url > /dev/null
    mkdir -p packdir && tar xzf pack.tar -C packdir
    cd packdir

    local version
    binpath=`find -type f -executable -exec file -i '{}' \; | grep 'x-executable; charset=binary' | cut -d':' -f1`
    echo "binpath $binpath"
    for bin in ${binpath[@]}; do
        echo "excuting"
        version=`$bin -V`
        echo "version: $version"
        if [[ ! $version =~ $hash_sum ]]
        then
            echo "$url wrong hash ----------"
        else
            echo "right hash ---------- "
        fi

        if [[ ! $version =~ $ver ]]
        then
            echo "$url wrong version -------- "
        else
            echo "right version ------------"
        fi
    done

    cd ..
    rm -r packdir
}


main() {
    local hash_file_url=$1
    local version=$2
    local platform=$3
    local py_url=$4

    # FIXME: python script url
    
    cd $HOME
    mkdir -p release_version_check
    cd release_version_check

    curl -sL -o hash.json $hash_file_url
    curl -sL -o extract.py $py_url 
    chmod +x extract.py
    
    local result=""
    local url
    hashes=( $(./extract.py hash.json) )
    length=${#hashes[@]}    
    for ((i=0 ; i<$length; i=$i+2 )); do 
        comp=${hashes[$i]}
        hash_sum=${hashes[$i+1]}
        url=$BASE_URL/$comp-$version-$platform.tar.gz

        check_hash $url $hash_sum $version
        result="`check_hash $url $hash_sum $version` $result"
        # echo $url
        # echo $hash_sum
        # echo "--------"1
    done
    
    cd ..
    rm -r release_version_check
    echo $result
    echo "done"
}

if [[ ! $# -eq 4 ]]; then
    echo "usage: hash_check.sh <hash_file_url> <version> <platform> <python_script_url>"
    echo "example: hash_check.sh http://127.0.0.1/hash.json v4.0.2 linux-amd64 http://127.0.0.1/extract.py"
    exit 1
fi

main $@