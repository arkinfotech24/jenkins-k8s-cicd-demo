pipeline {
  agent any
  parameters {
    choice(name: 'TARGET_ENV', choices: ['dev','test','prod'], description: 'Deployment target')
    string(name: 'IMAGE_TAG', defaultValue: 'latest', description: 'Image tag')
    booleanParam(name: 'SKIP_DEPLOY', defaultValue: false, description: 'Skip k8s apply')
  }
  environment {
    IMAGE = "ghcr.io/arkinfotech24/dummy-app:${IMAGE_TAG}"
    KUBECONFIG_CRED = 'kubeconfig-file-cred'
  }
  stages {
    stage('Checkout') { steps { checkout scm } }
    stage('Build & Push') {
      steps {
        sh '''
          docker buildx create --use || true
          docker buildx build --platform linux/arm/v7,linux/arm64,linux/amd64 -t ${IMAGE} --push .
        '''
      }
    }
    stage('Deploy') {
      when { expression { return !params.SKIP_DEPLOY } }
      steps {
        withCredentials([file(credentialsId: env.KUBECONFIG_CRED, variable: 'KUBECONFIG_FILE')]) {
          sh '''
            export KUBECONFIG=${KUBECONFIG_FILE}
            export IMAGE=${IMAGE}
            export TARGET_ENV=${TARGET_ENV}
            envsubst < k8s/app-deployment-template.yaml | kubectl apply -f -
            envsubst < k8s/app-service-template.yaml | kubectl apply -f -
            kubectl -n app-${TARGET_ENV} rollout status deployment/dummy-app --timeout=120s
          '''
        }
      }
    }
    stage('Verify') {
      steps {
        withCredentials([file(credentialsId: env.KUBECONFIG_CRED, variable: 'KUBECONFIG_FILE')]) {
          sh '''
            export KUBECONFIG=${KUBECONFIG_FILE}
            kubectl -n app-${TARGET_ENV} get pods -l app=dummy-app
          '''
        }
      }
    }
  }
}
