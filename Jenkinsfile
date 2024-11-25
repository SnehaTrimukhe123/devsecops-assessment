pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-2'
        AWS_CREDENTIALS = 'aws-credentials'  
        CLUSTER_NAME = 'DevSecOps-Cluster'  
        EMAIL_ID = 'snehatrimukhe11@gmail.com'  
    }

    parameters {
        string(name: 'MODULE', defaultValue: 'web', description: 'Module to build: web, api, or db')
    }

    stages {
        stage('Checkout Code') {
            steps {
                script {
                    git branch: 'develop', url: "https://github.com/SnehaTrimukhe123/devsecops-assessment.git"
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    def DOCKER_IMAGE = "162186035982.dkr.ecr.us-east-2.amazonaws.com/${params.MODULE}-dev"
                    def IMAGE_TAG = "${GIT_COMMIT}"

                    sh "docker build -t ${DOCKER_IMAGE}:${IMAGE_TAG} ."
                }
            }
        }

        stage('Push to ECR') {
            steps {
                script {
                    def DOCKER_IMAGE = "162186035982.dkr.ecr.us-east-2.amazonaws.com/${params.MODULE}-dev"
                    withCredentials([aws(credentialsId: AWS_CREDENTIALS)]) {
                        sh """
                            aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${DOCKER_IMAGE}
                            docker push ${DOCKER_IMAGE}:${GIT_COMMIT}
                        """
                    }
                }
            }
        }

        stage('Deploy to Development') {
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
            echo "Pipeline succeeded: ${params.MODULE} module built, pushed, and deployed successfully to Development."
            mail to: snehatrimukhe11@gmail.com, subject: "Jenkins Build Success - ${params.MODULE}", body: "The ${params.MODULE} module was successfully built, pushed to ECR, and deployed to the development environment."
        }
        failure {
            echo "Pipeline failed for ${params.MODULE} module in Development."
            mail to: snehatrimukhe11@gmail.com, subject: "Jenkins Build Failed - ${params.MODULE}", body: "The ${params.MODULE} module failed during the build, push, or deployment process to the development environment."
        }
    }
}

