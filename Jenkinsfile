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
                        // Build Docker image
                        def commitId = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                        def buildNumber = env.BUILD_NUMBER
                        def imageTag = "${commitId}-${buildNumber}"
                        sh "docker build -t web-app:${imageTag} ."
                        // Save Docker image tagging screenshot
                        // Example: sh 'docker_screenshot web docker_image_tagging.png'
                        // Upload to Google Drive
                        sh 'curl -F "file=@docker_image_tagging.png" https://drive.google.com/upload'
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
                        // Build Docker image
                        def commitId = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                        def buildNumber = env.BUILD_NUMBER
                        def imageTag = "${commitId}-${buildNumber}"
                        sh "docker build -t api-app:${imageTag} ."
                        // Save Docker image tagging screenshot
                        // Example: sh 'docker_screenshot api docker_image_tagging.png'
                        // Upload to Google Drive
                        sh 'curl -F "file=@docker_image_tagging.png" https://drive.google.com/upload'
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
                            // Save SonarQube result screenshot
                            // Example: sh 'sonarqube_screenshot sonarqube_result.png'
                            // Upload to Google Drive
                            sh 'curl -F "file=@sonarqube_result.png" https://drive.google.com/upload'
                        }
                    }
                }
                stage('OWASP Dependency-Check Scan') {
                    steps {
                        script {
                            echo 'Running Dependency-Check scan...'
                            sh 'dependency-check --project devsecops-assessment --out dependency-check-report.xml'
                            // Upload to Google Drive
                            sh 'curl -F "file=@dependency-check-report.xml" https://drive.google.com/upload'
                        }
                    }
                }
            }
        }
        stage('Anchore Image Scan') {
            steps {
                script {
                    echo 'Running Anchore Grype image scan...'
                    def commitId = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                    def buildNumber = env.BUILD_NUMBER
                    def imageTag = "${commitId}-${buildNumber}"
                    sh "grype web-app:${imageTag} -o json > anchore-scan.json"
                    // Upload to Google Drive
                    sh 'curl -F "file=@anchore-scan.json" https://drive.google.com/upload'
                    def hasCritical = sh(script: "jq '.matches[] | select(.vulnerability.severity == \"Critical\")' anchore-scan.json", returnStatus: true)
                    if (hasCritical == 0) {
                        error 'Critical vulnerabilities found. Failing the pipeline.'
                    }
                }
            }
        }
        stage('Push Image to ECR') {
            steps {
                script {
                    echo 'Pushing Docker images to ECR...'
                    def ecrRepo = "162186035982.dkr.ecr.us-west-2.amazonaws.com/my-repo"
                    def commitId = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                    def buildNumber = env.BUILD_NUMBER
                    def imageTag = "${commitId}-${buildNumber}"
                    withCredentials([string(credentialsId: 'ecr-credentials', variable: 'ECR_PASSWORD')]) {
                        sh 'aws ecr get-login-password --region your-region | docker login --username AWS --password-stdin your-account-id.dkr.ecr.your-region.amazonaws.com'
                        sh "docker tag web-app:${imageTag} ${ecrRepo}:web-${imageTag}"
                        sh "docker tag api-app:${imageTag} ${ecrRepo}:api-${imageTag}"
                        sh "docker push ${ecrRepo}:web-${imageTag}"
                        sh "docker push ${ecrRepo}:api-${imageTag}"
                    }
                }
            }
        }
        stage('Kubelinter Helm Charts') {
            steps {
                script {
                    echo 'Running Kubelinter on Helm charts...'
                    dir('application-helm-charts') {
                        sh 'kubelinter lint . --format json > kubelinter-report.json'
                        def hasHighPriorityIssues = sh(script: "jq '.reports[] | select(.severity == \"high\")' kubelinter-report.json", returnStatus: true)
                        if (hasHighPriorityIssues == 0) {
                            error 'High-priority issues detected by Kubelinter. Failing the pipeline.'
                        }
                    }
                }
            }
        }
        stage('Post Build Actions') {
            steps {
                script {
                    echo 'Running post-build actions...'
                    sh 'kubectl get pods'
                    // Replace with actual integration test commands for web and API services
                    sh './web/integration-test.sh'
                    sh './api/integration-test.sh'
                    // Email Notification
                    emailext(
                        to: 'snehatrimukhe11@gmail.com',
                        subject: "Build #${env.BUILD_NUMBER} - ${currentBuild.currentResult}",
                        body: """<p>Build Status: ${currentBuild.currentResult}</p>
                                 <p>Commit ID: ${commitId}</p>
                                 <p>Build Number: ${buildNumber}</p>
                                 <p>Build Link: ${env.BUILD_URL}</p>
                                 <p>Triggered by: ${currentBuild.getBuildCauses()[0].userId}</p>""",
                        attachmentsPattern: 'sonarqube_result.png,dependency-check-report.xml,anchore-scan.json,quality_gate_status.png,docker_image_tagging.png'
                    )
                    // Save email notification screenshot
                    // Example: sh 'email_screenshot email_notification.png'
                    // Upload to Google Drive
                    sh 'curl -F "file=@email_notification.png" https://drive.google.com/upload'
                }
            }
        }
    }
}

