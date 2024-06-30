
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
             /* post {
                always {
                     sh 'cat pylint.log'
                     recordIssues(
                          enabledForFailure: true,
                          aggregatingResults: true,
                          tools: [pyLint(name: 'Pylint', pattern: '**//* pylint.log')]
                     )

                }
             } */
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

        stage('Push NGINX Image') {
             steps { 
                withCredentials(
                   [usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASS')]
                ) { 
                    sh '''
                      docker login -u $DOCKER_USERNAME -p $DOCKER_PASS
                      docker push alexb853/$POLYBOT_IMG_NAME
                    ''' 
                   }
             }
        }

         stage('Push polybot img') {
               steps {
                  withCredentials(
                    [usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASS')]
                  ) {
                      sh '''
                        docker login -u $DOCKER_USERNAME -p $DOCKER_PASS
                        docker push alexb853/$POLYBOT_IMG_NAME
                      '''
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
