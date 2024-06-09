
pipeline {
    agent any

    environment{
       IMG_NAME = dockerbot:${BUILD_NUMBER}
    }
    stages {
        stage('Build') {
            steps {
                sh 'echo "Hello World!"'
                sh '''
                    echo "Multiline shell steps works too"
                    ls -lah
                '''
                    sh '''

                        # docker login -u alexb853 -p 
                        docker build -t $IMG_NAME .
                        docker tag $IMG_NAME alexb853/$IMG_NAME
                        docker push alexb853/$IMG_NAME
                    '''

            }
        }
    }
}
