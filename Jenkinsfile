
pipeline {
   agent {
       docker {
            image 'alexb853/jenkins-agent:latest'
            args '-v /tmp:/tmp'
       }
   }

    options {
        disableConcurrentBuilds()
        buildDiscarder(logRotator(daysToKeepStr: '30'))
        timestamps()
    }
     
    environment {
        POLYBOT_IMG_NAME = "dockerbot:${BUILD_NUMBER}"
        NGINX_IMG = "nginx:alpine"
        SNYK_IGNORE_FILE = 'snyk-ignore.json' 
    }

    stages {

        stage('Install Snyk CLI') {
            steps {
                   sh 'npm install -g snyk'
            }
        }

        stage('pull nginx img') {
            steps {
                   script { 
                          docker.image("${NGINX_IMG}").pull()
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

        stage('Snyk Scan') { 
            steps { 
               script {
                   withCredentials(
                            [string(credentialsId: 'snykAPI', variable: 'SNYK_TOKEN')]
                   ) {

                   sh "snyk auth ${SNYK_TOKEN}" 
                    
                   // Ensure the ignore file exists 
                   if (!fileExists(${SNYK_IGNORE_FILE})) { 
                     error "Snyk ignore file not found: ${SNYK_IGNORE_FILE}" 
                   }

                 // Perform the Snyk scan using the ignore file 
                 //sh "snyk test --ignore-policy=${snykIgnoreFile}" 
                 sh "snyk container test ${$POLYBOT_IMG_NAME} --file=${env.SNYK_IGNORE_FILE}"
                   }            
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
