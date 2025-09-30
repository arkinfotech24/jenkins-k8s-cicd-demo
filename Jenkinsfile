pipeline {
  agent any

  parameters {
    choice(
      name: 'TARGET_ENV',
      choices: ['dev', 'test', 'prod'],
      description: 'Select environment to deploy'
    )
    string(
      name: 'IMAGE_TAG',
      defaultValue: 'latest',
      description: 'Image tag to deploy'
    )
    booleanParam(
      name: 'SKIP_DEPLOY',
      defaultValue: false,
      description: 'Skip Kubernetes deployment'
    )
  }

  environment {
    IMAGE = "ghcr.io/arkinfotech24/dummy-app:${params.IMAGE_TAG}"
    KUBECONFIG_CRED = 'kubeconfig-file-cred'
    REGISTRY_CRED = 'registry-cred'
  }

  stages {

    stage('Validate Docker Environment') {
      steps {
        echo "[INFO] Validating Docker CLI and Buildx availability..."
        sh '''
          which docker || { echo "❌ Docker CLI not found"; exit 127; }
          docker version || { echo "❌ Docker daemon not reachable"; exit 127; }
          docker buildx version || { echo "❌ Docker Buildx not available"; exit 127; }
        '''
      }
    }

    stage('Checkout') {
      steps {
        echo "[INFO] Checking out source code..."
        checkout scm
      }
    }

    stage('Login to GHCR') {
      steps {
        echo "[INFO] Logging into GitHub Container Registry..."
        withCredentials([usernamePassword(credentialsId: env.REGISTRY_CRED, usernameVariable: 'GHCR_USERNAME', passwordVariable: 'GHCR_TOKEN')]) {
          sh 'echo "${GHCR_TOKEN}" | docker login ghcr.io -u "${GHCR_USERNAME}" --password-stdin'
        }
      }
    }

    stage('Build & Push Multi-Arch Image') {
      steps {
        echo "[INFO] Building and pushing multi-arch image..."
        sh '''
          docker buildx inspect multi-builder >/dev/null 2>&1 || docker buildx create --name multi-builder --use
          docker buildx build \
            --builder multi-builder \
            --platform linux/arm/v7,linux/arm64,linux/amd64 \
            -t ${IMAGE} \
            --push \
            .
        '''
      }
    }

    stage('Deploy to Kubernetes') {
      when {
        expression { return !params.SKIP_DEPLOY }
      }
      steps {
        echo "[INFO] Deploying to Kubernetes namespace: app-${params.TARGET_ENV}"
        withCredentials([file(credentialsId: env.KUBECONFIG_CRED, variable: 'KUBECONFIG_FILE')]) {
          sh '''
            export KUBECONFIG=${KUBECONFIG_FILE}
            export IMAGE=${IMAGE}
            export TARGET_ENV=${params.TARGET_ENV}

            kubectl apply -f k8s/namespaces.yaml
            envsubst < k8s/app-deployment-template.yaml | kubectl apply -f -
            envsubst < k8s/app-service-template.yaml | kubectl apply -f -

            echo "[INFO] Waiting for rollout to complete..."
            kubectl -n app-${TARGET_ENV} rollout status deployment/dummy-app --timeout=120s
          '''
        }
      }
    }

    stage('Verify Deployment') {
      when {
        expression { return !params.SKIP_DEPLOY }
      }
      steps {
        echo "[INFO] Verifying deployment in app-${params.TARGET_ENV}..."
        withCredentials([file(credentialsId: env.KUBECONFIG_CRED, variable: 'KUBECONFIG_FILE')]) {
          sh '''
            export KUBECONFIG=${KUBECONFIG_FILE}
            kubectl -n app-${TARGET_ENV} get pods -l app=dummy-app
            kubectl -n app-${TARGET_ENV} get svc dummy-app
          '''
        }
      }
    }
  }

  post {
    success {
      echo "[SUCCESS] Pipeline completed successfully for ${params.TARGET_ENV} with image tag ${params.IMAGE_TAG}"
    }
    failure {
      echo "[ERROR] Pipeline failed. Check logs for details."
    }
  }
}
