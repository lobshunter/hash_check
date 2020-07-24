#! /usr/bin/env python3

import sys
import paramiko
import argparse

REPO = "https://github.com/lobshunter/hash_check.git"
TMPDIR = "qa_hash_check"


def CMD(version: str, platform: str, hashfile_url: str) -> str:
    print("version: ", version)
    print("url:", hashfile_url)
    return f"""
    mkdir {TMPDIR}
    cd {TMPDIR}

    echo "starting"
    git clone {REPO}
    cd hash_check
    ./hash_check.sh {hashfile_url} {version} {platform}

    echo "exiting"
    cd ../..
    rm -rf {TMPDIR}
    """


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("username")
    parser.add_argument("host")
    parser.add_argument("password")
    parser.add_argument("hashfile_url")
    parser.add_argument("version")
    parser.add_argument("platform")

    # print("example: root 127.0.0.1 abc123 http://127.0.0.1/hash.json v4.0.1 darwin-amd64")

    args = parser.parse_args()
    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    client.connect(hostname=args.host, username=args.username,
                   password=args.password)

    command = CMD(version=args.version, platform=args.platform,
                  hashfile_url=args.hashfile_url)

    print(f"command {command}")
    stdin, stdout, stderr = client.exec_command(command)

    out: bytes = stdout.read()
    err: bytes = stderr.read()

    print(out.decode("utf8"))
    print(err.decode("utf8"))


if __name__ == "__main__":
    main()
