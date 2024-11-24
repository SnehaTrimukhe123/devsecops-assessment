pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-2'
        AWS_CREDENTIALS = 'aws-credentials'  // Jenkins AWS credentials ID
    }

    parameters {
        string(name: 'MODULE', defaultValue: 'web', description: 'Module to build: web, api, or db')
    }

    stages {
        stage('Checkout Code') {
            steps {
                script {
                    // Checkout the appropriate module
                    git branch: 'main', url: "https://github.com/yourusername/devsecops-assessment-${params.MODULE}.git"
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Define environment variables dynamically
                    def DOCKER_IMAGE = "162186035982.dkr.ecr.us-east-2.amazonaws.com/${params.MODULE}-dev"
                    def IMAGE_TAG = "${GIT_COMMIT}"
                    
                    // Build Docker image
                    sh "docker build -t ${DOCKER_IMAGE}:${IMAGE_TAG} ."
                }
            }
        }

        stage('Push to ECR') {
            steps {
                script {
                    def DOCKER_IMAGE = "162186035982.dkr.ecr.us-east-2.amazonaws.com/${params.MODULE}-dev"

                    // Login to AWS ECR and push the image
                    withCredentials([aws(credentialsId: AWS_CREDENTIALS)]) {
                        sh """
                            aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${DOCKER_IMAGE}
                            docker push ${DOCKER_IMAGE}:${GIT_COMMIT}
                        """
                    }
                }
            }
        }

        stage('Deploy to Dev') {
            steps {
                script {
                    def NAMESPACE = 'dev'
                    def HELM_CHART = "application-helm-charts/${params.MODULE}"

                    // Helm upgrade/install to Kubernetes in 'dev' namespace
                    sh "helm upgrade --install ${params.MODULE}-dev ${HELM_CHART} --namespace ${NAMESPACE}"
                }
            }
        }
    }

    post {
        success {
            echo "Pipeline succeeded: ${params.MODULE} module built, pushed, and deployed successfully."
        }
        failure {
            echo "Pipeline failed for ${params.MODULE} module."
        }
    }
}
