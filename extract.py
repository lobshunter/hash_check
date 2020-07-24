#! /usr/bin/env python3

import json
import sys


FILE_NAME = sys.argv[1]
COMMIT_SIFFIX = "_commit"
COMP_MAP = {
    "binlog": ["pump", "drainer"],
    "ticdc": ["cdc"],
    "lightning": ["tidb-lightning"],

    # normal
    "pd": ["pd"],
    "tikv": ["tikv"],
    "tidb": ["tidb"],
    "br": ["br"],
    "tiflash": ["tiflash"],
    "dumpling": ["dumpling"],

    # ignored
    # "importer": [],
    # "tools": [],
}


def maybe_expand_comp(comp: str, hash_sum: str) -> []:
    result = []
    if comp in COMP_MAP:
        for mapped_comp in COMP_MAP[comp]:
            result.append(mapped_comp)
            result.append(hash_sum)

    return result


def main():
    with open(FILE_NAME) as f:
        data: {} = json.load(fp=f)
        k: str
        hash_sum: str
        result = []
        for k, hash_sum in data.items():
            if k.endswith(COMMIT_SIFFIX):
                comp_name = k[:-len(COMMIT_SIFFIX)]
                result.extend(maybe_expand_comp(comp_name, hash_sum))

        print(*result, sep=' ')
        # [comp]-[version]-[platform-arch].tar.gz
        # e.g. :http://tiup-mirrors.pingcap.com/pd-v4.0.2-linux-amd64.tar.gz


if __name__ == "__main__":
    main()
