def call(Map params) {
    sh 'rm -rf output/'
    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: params.awscredentials, secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
        sh '$(aws ecr get-login --no-include-email --region eu-central-1)'
    }
    withCredentials([file(credentialsId: params.gpgsigningkey, variable: "SIGN_KEY_FILE")]) {
        sh """#!/usr/bin/env bash
set -euo pipefail +x

RAND=\$(shuf -ze -n20  {A..Z} {a..z} {0..9})
CONTAINER_NAME=package-builder-\${RAND}
IMAGE_NAME=768356633999.dkr.ecr.eu-central-1.amazonaws.com/package-builder
ARCH=\$(uname -m)

if [[ ! -z "\${SIGN_KEY_FILE:-}" ]]; then
    SIGN_KEY=\$(cat "\$SIGN_KEY_FILE")
fi

BUILD_NUMBER_ARG=""
if [[ ! -z "\${BUILD_NUMBER:-}" ]]; then
    BUILD_NUMBER_ARG="-e BUILD_NUMBER=\${BUILD_NUMBER}"
fi

DISTS=""
if [[ \${ARCH} == "x86_64" ]]; then
    DISTS="debian:buster ubuntu:eoan"
elif [[ \${ARCH} == "armv7l" ]]; then
    DISTS="debian:buster"
elif [[ \${ARCH} == "aarch64" ]]; then
    DISTS="ubuntu:eoan"
fi

for DIST in \${DISTS}; do
    OUTPUT_DIST=\${DIST//[:]/_}
    TAG=\${OUTPUT_DIST}_\${ARCH}_latest

    docker pull \${IMAGE_NAME}:\${TAG}
    RC=0
    docker run --name \${CONTAINER_NAME} -e SIGN_KEY_ID="\${SIGN_KEY_ID}" -e SIGN_KEY="\$SIGN_KEY" \${BUILD_NUMBER_ARG} \${IMAGE_NAME}:\${TAG} ${params.pack} || RC=\$?
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
    withAWS(region:'eu-central-1', credentials:params.awscredentials){
        s3Upload acl: 'Private', bucket: 'de.dd5jfk.openwebrx.debian-packages', cacheControl: '', excludePathPattern: '', includePathPattern: 'output/**/*.deb', metadatas: [''], path: '', redirectLocation: '', sseAlgorithm: '', text: '', workingDir: ''
        snsPublish(topicArn:'arn:aws:sns:eu-central-1:768356633999:RepositoryPush', subject:"New ${params.pack} package", message:'this is your message', messageAttributes: [])
    }
}