// Jenkins pipeline. Credentials to create in Jenkins (Manage Jenkins > Credentials):
//   aws-creds        Username with password  (username = AWS access key id, password = secret key)
//   acr-creds        Username with password  (ACR admin username / password)
//   dockerhub-creds  Username with password  (Docker Hub user / access token)
//   sonar-token      Secret text             (SonarQube token)
//   deploy-ssh-key   SSH Username with private key (username = ubuntu)

def withRegistryCreds(Closure body) {
    if (params.CLOUD == 'aws') {
        withCredentials([usernamePassword(credentialsId: 'aws-creds',
                usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) { body() }
    } else if (params.CLOUD == 'azure') {
        withCredentials([usernamePassword(credentialsId: 'acr-creds',
                usernameVariable: 'ACR_USERNAME', passwordVariable: 'ACR_PASSWORD')]) { body() }
    } else {
        withCredentials([usernamePassword(credentialsId: 'dockerhub-creds',
                usernameVariable: 'DOCKERHUB_USERNAME', passwordVariable: 'DOCKERHUB_TOKEN')]) { body() }
    }
}

pipeline {
    agent any

    parameters {
        choice(name: 'CLOUD', choices: ['aws', 'azure', 'dockerhub'], description: 'Registry / cloud to use')
        string(name: 'AWS_REGION', defaultValue: 'ap-south-1', description: 'AWS region (aws only)')
        string(name: 'ACR_LOGIN_SERVER', defaultValue: '', description: 'e.g. devopslabab12cd.azurecr.io (azure only)')
        string(name: 'DEPLOY_HOST', defaultValue: '', description: 'VM public IP (terraform output public_ip)')
        booleanParam(name: 'DEPLOY', defaultValue: true, description: 'Deploy after pushing')
    }

    environment {
        CLOUD            = "${params.CLOUD}"
        AWS_REGION       = "${params.AWS_REGION}"
        ACR_LOGIN_SERVER = "${params.ACR_LOGIN_SERVER}"
        DEPLOY_HOST      = "${params.DEPLOY_HOST}"
        SONAR_HOST_URL   = 'http://sonarqube:9000'   // reachable inside tools/docker-compose.yml
    }

    options {
        timestamps()
        disableConcurrentBuilds()
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
                script { env.IMAGE_TAG = sh(script: 'git rev-parse --short=7 HEAD', returnStdout: true).trim() }
            }
        }
        stage('Test') {
            steps { sh 'scripts/ci/test.sh' }
            post { always { junit allowEmptyResults: true, testResults: 'reports/junit.xml' } }
        }
        stage('SonarQube') {
            steps {
                withCredentials([string(credentialsId: 'sonar-token', variable: 'SONAR_TOKEN')]) {
                    sh 'scripts/ci/sonar.sh'
                }
            }
        }
        stage('Build image') {
            steps { sh 'scripts/ci/build.sh' }
        }
        stage('Trivy scan') {
            steps { sh 'scripts/ci/scan.sh' }
            post { always { archiveArtifacts artifacts: 'reports/trivy.json', allowEmptyArchive: true } }
        }
        stage('Push') {
            when { branch 'main' }
            steps { script { withRegistryCreds { sh 'scripts/ci/push.sh' } } }
        }
        stage('Deploy') {
            when { allOf { branch 'main'; expression { params.DEPLOY } } }
            steps {
                script {
                    withRegistryCreds {
                        withCredentials([sshUserPrivateKey(credentialsId: 'deploy-ssh-key',
                                keyFileVariable: 'SSH_KEY_FILE', usernameVariable: 'DEPLOY_USER')]) {
                            sh 'scripts/ci/deploy.sh'
                        }
                    }
                }
            }
        }
    }

    post {
        success { echo "Done: ${env.IMAGE_TAG} deployed to http://${params.DEPLOY_HOST}:30080" }
        cleanup { sh 'rm -rf .venv .ci || true' }
    }
}
