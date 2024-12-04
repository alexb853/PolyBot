pipeline {
    agent any

    stages {
        stage('Unittest') {
            steps {
            sh 'echo "error"'
            }
        }
        stage('Lint') {
            steps {
                sh 'echo "linting"'
            }
        }
        stage('Functional test') {
            steps {
                sh 'echo "testing"'
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
                                tools: [pyLint(name: 'Pylint', pattern: '**/pylint.log')]
                            )

                         }
                    }
          }
    }
}
