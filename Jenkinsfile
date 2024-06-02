
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
                # withCredentials([usernamePassword(credentialsId: 'mydockerlogin', variable: 'USERPASS')]) {
                    sh '''

                        # docker login -u alexb853 -p 
                        docker build -t dockerbot .
                        # docker tag ..
                        # docker push ...
                    '''

            }
        }
    }
}
