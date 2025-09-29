<<<<<<< HEAD
# jenkins-k8s-cicd-demo
=======
# Jenkins CI/CD Demo — Homelab Kubernetes

This repo contains a Jenkins pipeline and Kubernetes manifests to deploy a dummy app into isolated namespaces (`app-dev`, `app-test`, `app-prod`) without affecting existing services like Jenkins, Nextcloud, or Portainer.

## 🧠 Architecture

```mermaid
flowchart LR
  GH[GitHub repo] --> Jenkins[Jenkins (running on worker-node01)]
  Jenkins --> Registry[Container Registry]
  Jenkins --> K8s[Kubernetes Cluster]
  K8s --> AppDev[app-dev]
  K8s --> AppTest[app-test]
  K8s --> AppProd[app-prod]
  NFS[/nfs-jenkins-data] --> Jenkins
  NoteExisting[Existing apps: Jenkins, Nextcloud, Portainer] -.-> K8s
>>>>>>> 3fd1685 (Initial commit: Jenkins pipeline and k8s manifests)
