pipeline {
    agent any

    parameters {
        choice(name: 'QualityGate', choices: ['Pass', 'Fail'], description: 'Choose Quality Gate condition')
    }

    stages {
        stage('Clean Workspace') {
            steps {
                cleanWs()
                echo 'Workspace cleaned'
            }
        }
        stage('Build Web') {
            steps {
                script {
                    dir('web') {
                        echo 'Building web...'
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
                        sh 'python test.py'
                    }
                }
            }
        }
        stage('Static Code Analysis') {
            parallel {
                stage('SonarQube Analysis') {
                    steps {
                        script {
                            echo 'Running SonarQube analysis...'
                            withSonarQubeEnv('SonarQube') {
                                sh 'sonar-scanner'
                            }
                            // Example of how to save the screenshot (replace with actual command)
                            // sh 'take_screenshot sonarqube_result.png'
                            // Upload to Google Drive (example using curl)
                            sh 'curl -F "file=@sonarqube_result.png" https://drive.google.com/upload'
                        }
                    }
                }
                stage('OWASP Dependency-Check Scan') {
                    steps {
                        script {
                            echo 'Running Dependency-Check scan...'
                            sh 'dependency-check --project devsecops-assessment --out dependency-check-report.xml'
                            // Upload to Google Drive (example using curl)
                            sh 'curl -F "file=@dependency-check-report.xml" https://drive.google.com/upload'
                        }
                    }
                }
            }
        }
        stage('Quality Gate') {
            steps {
                script {
                    def qualityGate = params.QualityGate
                    echo "QualityGate parameter is set to ${qualityGate}"
                    
                    // Quality Gate conditions
                    def duplicatedLines = 5 // Example value; replace with actual value from SonarQube results
                    def securityRating = 'A' // Example value; replace with actual value from SonarQube results
                    def reliabilityRating = 'A' // Example value; replace with actual value from SonarQube results
                    def maintainabilityRating = 'A' // Example value; replace with actual value from SonarQube results
                    
                    if (qualityGate == 'Fail' && (duplicatedLines >= 5 || securityRating != 'A' || reliabilityRating != 'A' || maintainabilityRating != 'A')) {
                        error('Quality Gate conditions not met. Failing the pipeline.')
                    }
                    
                    // Example of how to save the screenshot (replace with actual command)
                    // sh 'take_screenshot quality_gate_status.png'
                    // Upload to Google Drive (example using curl)
                    sh 'curl -F "file=@quality_gate_status.png" https://drive.google.com/upload'
                }
            }
        }
        stage('Deploy') {
            steps {
                echo 'Deploying...'
                // Deployment steps
            }
        }
    }
}

