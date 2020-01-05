def call(Map params) {
    git 'https://github.com/jketterl/package-builder.git'
    sh 'rm -rf output/'
    withCredentials([file(credentialsId: params.gpgsigningkey, variable: "SIGN_KEY_FILE")]) {
        sh "./run.sh ${params.pack}"
    }
    s3Upload consoleLogLevel: 'INFO', dontWaitForConcurrentBuildCompletion: false, entries: [[bucket: 'de.dd5jfk.openwebrx.debian-packages', excludedFile: '', flatten: false, gzipFiles: false, keepForever: false, managedArtifacts: false, noUploadOnFailure: true, selectedRegion: 'eu-central-1', showDirectlyInBrowser: false, sourceFile: 'output/**/*.deb', storageClass: 'STANDARD', uploadFromSlave: true, useServerSideEncryption: false]], pluginFailureResultConstraint: 'FAILURE', profileName: params.s3profile, userMetadata: []
}