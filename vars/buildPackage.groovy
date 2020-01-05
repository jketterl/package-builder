def call(String arch, String pack, String gpgsigningkey, String S3profile) {
    agent { label arch }
    steps {
        withCredentials([file(credentialsId: gpgsigningkey, variable: "SIGN_KEY_FILE")]) {
            git 'https://github.com/jketterl/package-builder.git'
            sh 'rm -rf output/'
            sh "./run.sh ${pack}"
        }
    }
    post {
        always {
            s3Upload consoleLogLevel: 'INFO', dontWaitForConcurrentBuildCompletion: false, entries: [[bucket: 'de.dd5jfk.openwebrx.debian-packages', excludedFile: '', flatten: false, gzipFiles: false, keepForever: false, managedArtifacts: false, noUploadOnFailure: true, selectedRegion: 'eu-central-1', showDirectlyInBrowser: false, sourceFile: 'output/**/*.deb', storageClass: 'STANDARD', uploadFromSlave: true, useServerSideEncryption: false]], pluginFailureResultConstraint: 'FAILURE', profileName: S3profile, userMetadata: []
        }
    }
}