
pipeline {
    agent any
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
                        docker build -t dockerbot:${BUILD_NUMBER} .
                        docker tag dockerbot:latest dockerbot:v1.0
                        docker push alexb853/dockerbot:${BUILD_NUMBER}
                    '''

            }
        }
    }
}
