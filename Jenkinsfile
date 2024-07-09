@Library('Jenkins-library') _

pipeline {
   agent any

    options {
        disableConcurrentBuilds()
        buildDiscarder(logRotator(daysToKeepStr: '30'))
        timestamps()
    }
     
    environment {
        POLYBOT_IMG_NAME = "dockerbot:${BUILD_NUMBER}"
        NGINX_IMG = "nginx:alpine"
        DOCKERHUB_CREDENTIALS = credentials('dockerhub') // Jenkins credentials ID
        APP_IMAGE_NAME = 'python-app-image'
        WEB_IMAGE_NAME = 'web-image'
        DOCKER_COMPOSE_FILE = 'docker-compose.yml'
        BUILD_DATE = new Date().format('yyyyMMdd-HHmmss')
        IMAGE_TAG = "v1.0.0-${BUILD_NUMBER}-${BUILD_DATE}"
        SNYK_TOKEN = credentials('snykAPI')
        NEXUS_PROTOCOL = "http"
        NEXUS_URL = "77.125.243.66:8888"
        NEXUS_REPOSITORY = "my-docker-repo"
        NEXUS_CREDENTIALS_ID = "nexus"
    }

    stages {

        stage('Build and Deploy') {
            steps {
                script {
                    buildAndDeploy()
                }
            }
        }

        stage('pull nginx img') {
            steps {
                   script { 
                          docker.image("${NGINX_IMG}").pull()
                   }
            }
        }
        stage('Static Code Linting') {
            steps {
                   sh 'python3 -m pylint -f parseable --reports=no *.py > pylint.log'
            }
             post {
                always {
                     sh 'cat pylint.log'
                     recordIssues(
                          enabledForFailure: true,
                          aggregatingResults: true,
                          tools: [pyLint(name: 'Pylint', pattern: '**//*  *//* pylint.log')]
                     )

                }
             }
        }
        stage('Unit Tests') {
            steps {
                // Ensure Python requirements are installed
                sh 'pip3 install pytest'
                // Run pytest for unit tests
                sh 'python3 -m pytest --junitxml=results.xml tests/*.py'
            }
            post {
                always {
                    junit allowEmptyResults: true, testResults: 'results.xml'
                }
            }
        }
        stage('Build polybot Image') {
             steps { 
                   script {
 
                      sh '''
                         docker build -t $POLYBOT_IMG_NAME .
                         docker tag $POLYBOT_IMG_NAME alexb853/$POLYBOT_IMG_NAME
                        '''
                   }
             }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    // Build Docker image using docker-compose
                    sh 'docker-compose -f ${DOCKER_COMPOSE_FILE} build'
                }
            }
        }
        stage('Snyk Container Test') {
            steps {
                 script {
                    withCredentials([string(credentialsId: 'snykAPI', variable: 'SNYK_TOKEN')]) {
                    sh 'snyk auth ${SNYK_TOKEN}'
                    sh 'snyk container test ${APP_IMAGE_NAME}:latest --policy-path=.snyk'
                    sh 'snyk container test ${APP_IMAGE_NAME}:latest --file=Dockerfile'
                    }
                 }
            }
        }
        stage('Login to Nexus Repository') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: "${NEXUS_CREDENTIALS_ID}", passwordVariable: 'PASSWORD', usernameVariable: 'USERNAME')]) {
                        sh "docker login -u ${USERNAME} -p ${PASSWORD} ${NEXUS_PROTOCOL}://${NEXUS_URL}/repository/${NEXUS_REPOSITORY}"
                    }
                }
            }
        }
        stage('Tag and Push To Nexus') {
            steps {
                script {
                sh '''
                    docker tag ${APP_IMAGE_NAME}:latest ${NEXUS_URL}/${APP_IMAGE_NAME}:${IMAGE_TAG}
                    docker push ${NEXUS_URL}/${APP_IMAGE_NAME}:${IMAGE_TAG}
                    docker tag ${WEB_IMAGE_NAME}:latest ${NEXUS_URL}/${WEB_IMAGE_NAME}:${IMAGE_TAG}
                    docker push ${NEXUS_URL}/${WEB_IMAGE_NAME}:${IMAGE_TAG}
                 '''
                }
            }
        }
        stage('Tag and push images') {
            steps {
                script {
                    withCredentials(
                    [usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASS')]){
                    sh '''
                    docker login -u ${DOCKER_USERNAME} -p ${DOCKER_PASS}
                    docker tag ${APP_IMAGE_NAME}:latest ${DOCKER_USERNAME}/${APP_IMAGE_NAME}:${IMAGE_TAG}
                    docker push ${DOCKER_USERNAME}/${APP_IMAGE_NAME}:${IMAGE_TAG}
                    docker tag ${WEB_IMAGE_NAME}:latest ${DOCKER_USERNAME}/${WEB_IMAGE_NAME}:${IMAGE_TAG}
                    docker push ${DOCKER_USERNAME}/${WEB_IMAGE_NAME}:${IMAGE_TAG}
                    '''
                    }
                }
            }
        }
        stage('Deploy to Development') {
            when {
                branch 'develop'
            }
            steps {
                script {
                    withCredentials(
                    [usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASS')]){
                        sh 'docker-compose -f docker-compose-dev.yaml pull'
                        sh 'docker-compose -f docker-compose-dev.yaml up -d'
                    }
                }
            }
        }
        stage('Deploy to Staging') {
            when {
                branch 'staging'
            }
            steps {
                script {
                    withCredentials(
                    [usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASS')]){
                        sh 'docker-compose -f docker-compose-staging.yaml pull'
                        sh 'docker-compose -f docker-compose-staging.yaml up -d'
                    }
                }
            }
        }
        stage('Deploy to Production') {
            when {
                branch 'master'
            }
            steps {
                script {
                    withCredentials(
                    [usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASS')]){
                        sh 'docker-compose -f docker-compose.yaml pull'
                        sh 'docker-compose -f docker-compose.yaml up -d'
                    }
                }
            }
        }
        stage('Trigger Deploy') {
           steps {
               build job: 'BotDeploy', wait: false, parameters: [
               string(name: 'IMAGE_URL', value: "alexb853/$POLYBOT_IMG_NAME")
               ]
           }
        }
        stage('Sleep') {
          steps { 
             sleep 20
          } 
        }
    }


    post {
          always { 
            cleanWs()
          } 
    }
}
