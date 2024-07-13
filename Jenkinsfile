//@Library('Jenkins-library') _

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
        NEXUS_URL = "172.28.93.131:8888"
        NEXUS_REPOSITORY = "my-docker-repo"
        NEXUS_CREDENTIALS_ID = "nexus"
    }

     stages {
        stage('Build Docker Image') {
            steps {
                script {
                    // Build Docker image using docker-compose
                    sh 'docker-compose -f ${DOCKER_COMPOSE_FILE} build'
                }
            }
        }
        stage('Static Code Linting') {
             steps {
                    sh 'pip install pylint'
                    sh 'python3 -m pylint -f parseable --reports=no **/*.py > pylint.log'
             }
              post {
                 always {
                      sh 'cat pylint.log'
//                       recordIssues(
//                            enabledForFailure: true,
//                            aggregatingResults: true,
//                            tools: [pyLint(name: 'Pylint', pattern: '**/pylint.log')]
//                       )

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
        stage('Snyk Container Test') {
            steps {
                 script {
                    withCredentials([string(credentialsId: 'snykAPI', variable: 'SNYK_TOKEN')]) {
                    sh 'snyk auth ${SNYK_TOKEN}'
                    sh 'snyk container test ${APP_IMAGE_NAME}:latest --policy-path=.snyk'
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

        stage('Trigger Deploy') {
            steps {
                echo "Deploy to k8s"
            }
        }
    }

    post {
          always {
            cleanWs()
          }
    }
}