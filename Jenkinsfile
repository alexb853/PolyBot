
pipeline {
    agent any

    environment {
        IMG_NAME = "dockerbot:${BUILD_NUMBER}"
    }
    stages {
        stage('Build') {
            steps {
            withCredentials(
               [usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASS')]
            ) {
                sh '''
                      docker login -u $DOCKER_USERNAME -p DOCKER_PASS
                      docker build -t $IMG_NAME .
                      docker tag $IMG_NAME alexb853/$IMG_NAME
                      docker push alexb853/$IMG_NAME
                    '''
            }

            }
        }
    }
}
