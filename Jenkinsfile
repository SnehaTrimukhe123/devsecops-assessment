pipeline {
    agent any
    environment {
        ECR_REPO = "162186035982.dkr.ecr.us-west-2.amazonaws.com/web-app-image"
    }
    stages {
        stage('Build') {
            steps {
                script {
                    def tag = env.BRANCH_NAME == 'master' ? 'latest' : 'develop'
                    echo "Building for ${env.BRANCH_NAME} branch with tag ${tag}..."
                    sh "docker build -t ${ECR_REPO}:${tag} ."
                }
            }
        }
        stage('Push') {
            steps {
                script {
                    def tag = env.BRANCH_NAME == 'master' ? 'latest' : 'develop'
                    echo "Pushing for ${env.BRANCH_NAME} branch with tag ${tag}..."
                    sh "docker push ${ECR_REPO}:${tag}"
                }
            }
        }
        stage('Deploy') {
            steps {
                script {
                    def tag = env.BRANCH_NAME == 'master' ? 'latest' : 'develop'
                    def namespace = env.BRANCH_NAME == 'master' ? 'prod' : 'dev'
                    echo "Deploying to ${namespace} namespace with tag ${tag}..."
                    sh "helm upgrade --install web-app ./web --namespace ${namespace} --set image.repository=${ECR_REPO} --set image.tag=${tag}"
                }
            }
        }
    }
}

