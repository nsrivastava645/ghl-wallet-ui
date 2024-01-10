pipeline {
    agent {
        label 'linux'
    }
    environment {
        NODEJS_VERSION = '16'
        NPM_VERSION = 'latest'
    }

    stages {
        stage('Install') {
            steps {
                script {
                    echo 'install'
                    sh "n ${NODEJS_VERSION}"
                    sh "npm install -y npm@${NPM_VERSION}"
                }
            }
        }

        stage('Pre Build') {
            steps {
                script {
                    echo 'pre_build'
                    sh 'npm install'
                }
            }
        }

        stage('Build') {
            steps {
                script {
                    echo 'build'
                    echo "Build started on ${env.BUILD_NUMBER}"
                    sh "npm run build-dev"
                }
            }
        }

        stage('Post Build') {
            steps {
                script {
                    echo 'post_build'
                    echo "Build completed on ${env.BUILD_NUMBER}"
                }
            }
        }
    }

    post {
        success {
            archiveArtifacts artifacts: '**/*', fingerprint: true
            s3Upload(bucket: 'myjenkinsbuckettest', includePathPattern: '**/*', pathStyleAccess: true)
        }
    }
}
