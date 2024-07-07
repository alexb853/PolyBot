@Library('Jenkins-library') _

buildAndDeploy()

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
    }

    stages {

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
        stage('Debugging') {
            steps {
                script {
                    // Print current directory and list files for debugging
                    sh 'pwd'
                    sh 'ls -la'
                }
            }
        }
        stage('Snyk Container Test') {
            steps {
                script {
                    // Test Docker image for vulnerabilities
                    withCredentials([string(credentialsId: 'snykAPI', variable: 'SNYK_TOKEN')]) {
                        sh 'snyk auth ${SNYK_TOKEN}'
                        sh 'snyk container test ${APP_IMAGE_NAME}:latest --policy-path=.snyk'
                        sh 'snyk container test ${APP_IMAGE_NAME}:latest --file=Dockerfile'
                    }
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
