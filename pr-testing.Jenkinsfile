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
    }
}