def call(Map params) {
    sh 'rm -rf output/'
    withAWS(region:'eu-central-1', credentials:params.awscredentials){
        sh "${ecrLogin()}"
        withCredentials([file(credentialsId: params.gpgsigningkey, variable: "SIGN_KEY_FILE")]) {
            sh """#!/usr/bin/env bash
set -euo pipefail +x

RAND=\$(shuf -ze -n20  {A..Z} {a..z} {0..9})
CONTAINER_NAME=package-builder-\${RAND}
IMAGE_NAME=768356633999.dkr.ecr.eu-central-1.amazonaws.com/package-builder
ARCH=\$(uname -m)

SIGN_KEY=\$(cat "\$SIGN_KEY_FILE")

BUILD_NUMBER_ARG=""
if [[ ! -z "${params.releaseBranch}" ]]; then
    BUILD_NUMBER_ARG="-e RELEASE_BRANCH=${params.releaseBranch}"
else if [[ ! -z "\${BUILD_NUMBER:-}" ]]; then
    BUILD_NUMBER_ARG="-e BUILD_NUMBER=\${BUILD_NUMBER}"
fi

for DIST in ${params.dists.join(" ")}; do
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
        s3Upload acl: 'Private', bucket: 'de.dd5jfk.openwebrx.debian-packages', cacheControl: '', excludePathPattern: '', includePathPattern: '**/*.deb', metadatas: [''], path: '', redirectLocation: '', sseAlgorithm: '', workingDir: 'output'
        snsPublish(topicArn:'arn:aws:sns:eu-central-1:768356633999:RepositoryPush', subject:"New ${params.pack} package", message:'this is your message')
    }
}