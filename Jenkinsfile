pipeline {
    agent any
    environment {
        VERSION = "${BUILD_ID}"
        AWS_ACCOUNT_ID = credentials('account_id')
        AWS_DEFAULT_REGION = "us-east-1"
        IMAGE_REPO_NAME = "wiz_exercise"
        IMAGE_TAG = "${BUILD_ID}"
        REPOSITORY_URI = "775012328020.dkr.ecr.us-east-1.amazonaws.com/wiz_exercise"
    }

    stages {
        stage('Login to AWS ECR') {
            environment {
                AWS_ACCESS_KEY_ID = credentials('aws_access_key_id')
                AWS_SECRET_ACCESS_KEY = credentials('aws_secret_access_key')
            }
            steps {
                sh '''
                    aws ecr get-login-password --region $AWS_DEFAULT_REGION | \
                    docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    dockerImage = docker.build("${IMAGE_REPO_NAME}:${IMAGE_TAG}")
                }
            }
        }

        stage('Push Docker Image to ECR') {
            steps {
                sh '''
                    docker tag $IMAGE_REPO_NAME:$IMAGE_TAG $REPOSITORY_URI:$IMAGE_TAG
                    docker push $REPOSITORY_URI:$IMAGE_TAG
                '''
            }
        }

        stage('Deploy on EKS') {
            environment {
                AWS_ACCESS_KEY_ID = credentials('aws_access_key_id')
                AWS_SECRET_ACCESS_KEY = credentials('aws_secret_access_key')
            }
            steps {
                dir('kubernetes/') {
                    sh '''
                        aws eks update-kubeconfig --name myAppp-eks-cluster --region $AWS_DEFAULT_REGION

                        helm upgrade --install djangoapp myapp/ \
                          --set image.repository=$REPOSITORY_URI \
                          --set image.tag=$VERSION
                    '''
                }
            }
        }
    }
}
