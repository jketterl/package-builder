def call(Map params) {
    sh 'rm -rf output/'
    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: params.awscredentials, secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
        sh '$(aws ecr get-login --no-include-email --region eu-central-1)'
    }
    withCredentials([file(credentialsId: params.gpgsigningkey, variable: "SIGN_KEY_FILE")]) {
        sh """#!/usr/bin/env bash
set -euo pipefail +x

CONTAINER_NAME=package-builder
ARCH=\$(uname -m)

if [[ ! -z "\${SIGN_KEY_FILE:-}" ]]; then
    SIGN_KEY=\$(cat "\$SIGN_KEY_FILE")
fi

BUILD_NUMBER_ARG=""
if [[ ! -z "\${BUILD_NUMBER:-}" ]]; then
    BUILD_NUMBER_ARG="-e BUILD_NUMBER=\${BUILD_NUMBER}"
fi

for DIST in `cat dists/\$ARCH`; do
    OUTPUT_DIST=\${DIST//[:]/_}
    TAG = \${OUTPUT_DIST}_\${ARCH}_latest

    docker pull 768356633999.dkr.ecr.eu-central-1.amazonaws.com/package-builder:\${TAG}
    RC = 0
    docker run --name package-builder -e SIGN_KEY_ID="\${SIGN_KEY_ID}" -e SIGN_KEY="\$SIGN_KEY" \${BUILD_NUMBER_ARG} 768356633999.dkr.ecr.eu-central-1.amazonaws.com/package-builder:\${TAG} ${params.pack} || RC=\$?
    if [[ \${RC} ]]; then
        docker cp \${CONTAINER_NAME}:/packages.tar.gz . || RC=\$?
    fi
    docker rm \${CONTAINER_NAME}
    if [[ ! \${RC} ]]; then
        exit \${RC}
    fi
    mkdir -p output/\${ARCH}/\${OUTPUT_DIST}
    tar xvfz packages.tar.gz -C output/\${ARCH}/\${OUTPUT_DIST}
    rm packages.tar.gz
done
    """
    }
    s3Upload consoleLogLevel: 'INFO', dontWaitForConcurrentBuildCompletion: false, entries: [[bucket: 'de.dd5jfk.openwebrx.debian-packages', excludedFile: '', flatten: false, gzipFiles: false, keepForever: false, managedArtifacts: false, noUploadOnFailure: true, selectedRegion: 'eu-central-1', showDirectlyInBrowser: false, sourceFile: 'output/**/*.deb', storageClass: 'STANDARD', uploadFromSlave: true, useServerSideEncryption: false]], pluginFailureResultConstraint: 'FAILURE', profileName: params.s3profile, userMetadata: []
}