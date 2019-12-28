#!/usr/bin/env bash
set -euo pipefail

mkdir -p /tmp/build
cd /tmp/build

for PACKAGE in `ls /packages`; do
    echo "Building package $PACKAGE"
    /packages/$PACKAGE/build.sh
done

export GPG_TTY=$(tty)
gpg --batch --import <(echo "$SIGN_KEY")

for PACKAGE in `ls *.deb`; do
    debsigs --sign=maint -k $SIGN_KEY_ID $PACKAGE
done

tar cvfz /packages.tar.gz *.deb