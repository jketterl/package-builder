#!/usr/bin/env bash
set -euo pipefail

mkdir -p /tmp/output
mkdir -p /tmp/build
cd /tmp/build

PACKAGES=$(cd /packages && ls -d *)
if [[ ! -z "${1:-}" ]]; then
    DEPS=""
    for PACKAGE in ${PACKAGES}; do
        if [[ ${PACKAGE:3} == $1 ]]; then
            break
        fi
        if [[ -e /packages/${PACKAGE}/replacement ]]; then
            DEPS="$DEPS $(cat /packages/${PACKAGE}/replacement)"
        fi
    done
    if [[ ! -z "${DEPS}" ]]; then
        apt-get update && apt-get install -y ${DEPS}
    fi
    PACKAGES=$(cd /packages && ls -d ??-${1})
fi
echo "package list: ${PACKAGES}"

for PACKAGE in ${PACKAGES}; do
    echo "Building package $PACKAGE"
    /packages/$PACKAGE/build.sh

    if ls *.deb; then
        dpkg -i *.deb
        for DEB in `ls *.deb`; do
            mv $DEB /tmp/output
        done
    fi
done

export GPG_TTY=$(tty)
gpg --batch --import <(echo "$SIGN_KEY")

cd /tmp/output

for PACKAGE in `ls *.deb`; do
    debsigs --sign=maint -k $SIGN_KEY_ID $PACKAGE
done

tar cvfz /packages.tar.gz *.deb