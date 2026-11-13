pipeline {
    agent any

    environment {
        DOCKERHUB_USERNAME = "baigmazhar"
        BACKEND_IMAGE      = "${DOCKERHUB_USERNAME}/employee-backend"
        FRONTEND_IMAGE     = "${DOCKERHUB_USERNAME}/employee-frontend"
        // K3S_SERVER_IP is configured in Jenkins → Manage Jenkins → Configure System
        K3S_IP             = "${env.K3S_SERVER_IP}"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
                echo "Code checked out from GitHub successfully"
            }
        }

        stage('Build Backend Docker Image') {
            steps {
                echo "Building backend Docker image..."
                dir('backend') {
                    sh "docker build -t ${BACKEND_IMAGE}:${BUILD_NUMBER} -t ${BACKEND_IMAGE}:latest ."
                }
            }
        }

        stage('Build Frontend Docker Image') {
            steps {
                echo "Building frontend Docker image..."
                dir('frontend') {
                    // Pass the real backend URL as build arg so React bakes it in
                    sh """
                        docker build \
                          --build-arg REACT_APP_SERVER_URL=http://${K3S_IP}:30800/employees \
                          -t ${FRONTEND_IMAGE}:${BUILD_NUMBER} \
                          -t ${FRONTEND_IMAGE}:latest .
                    """
                }
            }
        }

        stage('Push Images to DockerHub') {
            steps {
                echo "Pushing images to DockerHub..."
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-credentials',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh "echo ${DOCKER_PASS} | docker login -u ${DOCKER_USER} --password-stdin"
                    sh "docker push ${BACKEND_IMAGE}:${BUILD_NUMBER}"
                    sh "docker push ${BACKEND_IMAGE}:latest"
                    sh "docker push ${FRONTEND_IMAGE}:${BUILD_NUMBER}"
                    sh "docker push ${FRONTEND_IMAGE}:latest"
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                echo "Deploying to K3s Kubernetes cluster..."
                withCredentials([file(credentialsId: 'k3s-kubeconfig', variable: 'KUBECONFIG')]) {
                    sh "kubectl apply -f k8s/namespace.yaml"
                    sh "kubectl apply -f k8s/postgres-deployment.yaml"
                    sh "kubectl apply -f k8s/backend-deployment.yaml"
                    sh "kubectl apply -f k8s/frontend-deployment.yaml"

                    // Force pods to pull the latest image
                    sh "kubectl rollout restart deployment/backend  -n employee-app"
                    sh "kubectl rollout restart deployment/frontend -n employee-app"

                    // Wait until deployments are healthy
                    sh "kubectl rollout status deployment/backend  -n employee-app --timeout=180s"
                    sh "kubectl rollout status deployment/frontend -n employee-app --timeout=180s"
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                withCredentials([file(credentialsId: 'k3s-kubeconfig', variable: 'KUBECONFIG')]) {
                    sh "kubectl get pods     -n employee-app"
                    sh "kubectl get services -n employee-app"
                    echo "============================================"
                    echo " Frontend : http://${K3S_IP}:30080"
                    echo " Backend  : http://${K3S_IP}:30800"
                    echo "============================================"
                }
            }
        }
    }

    post {
        success {
            echo "Pipeline succeeded! Application is live at http://${K3S_IP}:30080"
        }
        failure {
            echo "Pipeline failed. Check the stage logs above."
        }
        always {
            // Clean up local Docker images to free disk space on Jenkins
            sh "docker rmi ${BACKEND_IMAGE}:${BUILD_NUMBER} || true"
            sh "docker rmi ${FRONTEND_IMAGE}:${BUILD_NUMBER} || true"
        }
    }
}
