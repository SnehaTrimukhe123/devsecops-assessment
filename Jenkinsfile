pipeline {
    agent any

    stages {
        stage('Build Web') {
            steps {
                script {
                    dir('web') {
                        echo 'Building web...'
                        // Add your web build steps here
                        sh 'npm install'
                        sh 'npm run build'
                    }
                }
            }
        }
        stage('Build API') {
            steps {
                script {
                    dir('api') {
                        echo 'Building API...'
                        // Add your API build steps here
                        sh 'pip install -r requirements.txt'
                        sh 'python app.py'
                    }
                }
            }
        }
        stage('Test Web') {
            steps {
                script {
                    dir('web') {
                        echo 'Testing web...'
                        // Add your web test steps here
                        sh 'npm test'
                    }
                }
            }
        }
        stage('Test API') {
            steps {
                script {
                    dir('api') {
                        echo 'Testing API...'
                        // Add your API test steps here
                        sh 'python test.py'
                    }
                }
            }
        }
        stage('Deploy') {
            steps {
                echo 'Deploying...'
                // Add your deploy steps here
                // Example: sh 'deploy.sh'
            }
        }
    }
}

