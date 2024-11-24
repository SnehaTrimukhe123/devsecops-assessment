pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-2' // AWS region for ECR
        ECR_REPOSITORY = 'web-dev' // ECR repository name for Web application
        DOCKER_IMAGE = '162186035982.dkr.ecr.us-east-2.amazonaws.com/web-dev' // Full ECR URL for the Web image
        IMAGE_TAG = "${GIT_COMMIT}-${BUILD_NUMBER}" // Use Git commit hash and build number as image tag
        NAMESPACE = 'web' // Kubernetes namespace
        AWS_CREDENTIALS = 'aws-credentials' // Jenkins AWS credentials ID
    }

    stages {
        stage('Clean Workspace') {
            steps {
                cleanWs()
            }
        }

        stage('Static Code Analysis') {
            parallel {
                stage('SonarQube Analysis') {
                    steps {
                        script {
                            withSonarQubeEnv('SonarQube') {
                                sh 'sonar-scanner'
                            }
                        }
                        archiveArtifacts artifacts: '**/sonarqube_result.png'
                    }
                }
                stage('OWASP Dependency-Check') {
                    steps {
                        sh 'dependency-check --project web-app --out dependency-check-report.xml'
                        archiveArtifacts artifacts: 'dependency-check-report.xml'
                    }
                }
            }
        }

        stage('Run Tests') {
            steps {
                sh 'npm install'
                sh 'npm run test'
                junit 'tests/*.xml'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $DOCKER_IMAGE:$IMAGE_TAG .'
                archiveArtifacts artifacts: '**/docker_image_tagging.png'
            }
        }

        stage('Anchore Grype Image Scan') {
            steps {
                sh '''
                grype $DOCKER_IMAGE:$IMAGE_TAG -o json > anchore-scan.json
                '''
                archiveArtifacts artifacts: 'anchore-scan.json'
            }
        }

        stage('Push Docker Image to ECR') {
            steps {
                script {
                    withCredentials([aws(credentialsId: AWS_CREDENTIALS)]) {
                        sh '''
                            aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $DOCKER_IMAGE
                        '''
                    }
                    sh 'docker push $DOCKER_IMAGE:$IMAGE_TAG'
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    sh '''
                        helm upgrade --install web-dev application-helm-charts/web --namespace $NAMESPACE --set image.tag=$IMAGE_TAG
                    '''
                }
            }
        }
    }

    post {
        success {
            mail to: 'snehatrimukhe11@gmail.com',
                 subject: "Build Success: ${env.BUILD_NUMBER} - Web",
                 body: "Web Build ${env.BUILD_NUMBER} completed successfully for ${env.JOB_NAME}. Commit: ${env.GIT_COMMIT}"
        }
        failure {
            mail to: 'snehatrimukhe11@gmail.com',
                 subject: "Build Failed: ${env.BUILD_NUMBER} - Web",
                 body: "Web Build ${env.BUILD_NUMBER} failed for ${env.JOB_NAME}. Commit: ${env.GIT_COMMIT}"
        }
    }
}

