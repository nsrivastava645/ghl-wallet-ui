pipeline {
    agent any

    environment {
        NODEJS_VERSION = '16'
        NPM_VERSION = 'latest'
    }
    tools {
        nodejs
    }

    stages {
        stage('Pre Build') {
            steps {
                script {
                    echo 'Pre Build'
                    sh "npm install -g npm@${NPM_VERSION}"
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
