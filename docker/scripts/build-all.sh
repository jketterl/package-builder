#!/usr/bin/env bash
set -euo pipefail

mkdir -p /tmp/output
mkdir -p /tmp/build
cd /tmp/build

for PACKAGE in `ls /packages`; do
    echo "Building package $PACKAGE"
    /packages/$PACKAGE/build.sh

    dpkg -i *.deb
    for DEB in `ls *.deb`; do
        mv $DEB /tmp/output
    done
done

export GPG_TTY=$(tty)
gpg --batch --import <(echo "$SIGN_KEY")

cd /tmp/output

for PACKAGE in `ls *.deb`; do
    debsigs --sign=maint -k $SIGN_KEY_ID $PACKAGE
done

tar cvfz /packages.tar.gz *.deb