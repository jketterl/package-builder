def call(Map params) {
    git 'https://github.com/jketterl/package-builder.git'
    sh 'rm -rf output/'
    withCredentials([file(credentialsId: params.gpgsigningkey, variable: "SIGN_KEY_FILE")]) {
        sh "./run.sh ${params.pack}"
    }
}