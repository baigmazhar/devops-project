# Employee Management System — DevOps Project

## Stack
| Layer | Tool |
|---|---|
| Frontend | ReactJS (served via Nginx) |
| Backend | Go (Golang 1.19) |
| Database | PostgreSQL 14 |
| Containerization | Docker |
| CI/CD | GitHub Actions |
| Orchestration | Kubernetes (K3s on EC2) |
| Infrastructure | Terraform (AWS EC2) |
| Cloud | AWS us-east-1 (N. Virginia) |

## Architecture
```
GitHub Push (main branch)
    ↓
GitHub Actions
    → Build Docker images (backend + frontend)
    → Push to DockerHub
    → Deploy to K3s via kubectl
         ↓
K3s Kubernetes (EC2 t3.micro - us-east-1)
    → frontend pod  → NodePort 30080  (public)
    → backend pod   → NodePort 30800  (public)
    → postgres pod  → ClusterIP       (internal only)
```

## Live URLs
- **Frontend App:** http://3.236.189.81:30080
- **Backend API:** http://3.236.189.81:30800
- **GitHub Actions:** https://github.com/baigmazhar/devops-project/actions

## DockerHub Images
- `baigmazhar/employee-backend:latest`
- `baigmazhar/employee-frontend:latest`

## Repository Structure
```
devops-project/
├── .github/workflows/ci-cd.yml  ← GitHub Actions CI/CD pipeline
├── backend/
│   ├── Dockerfile               ← 2-stage Go build
│   └── main.go, go.mod ...      ← Go source code
├── frontend/
│   ├── Dockerfile               ← Node build + Nginx serve
│   ├── nginx.conf               ← Nginx config
│   └── src/, package.json ...   ← React source code
├── k8s/
│   ├── namespace.yaml
│   ├── postgres-deployment.yaml
│   ├── backend-deployment.yaml
│   └── frontend-deployment.yaml
├── terraform/
│   ├── main.tf                  ← VPC + EC2 + Security Groups
│   ├── variables.tf
│   ├── outputs.tf
│   ├── user_data_k3s.sh         ← Auto-installs K3s on EC2 boot
│   └── ...
└── KNOWLEDGE_BASE.md            ← Full project documentation
```

## How to Deploy

### 1. Provision Infrastructure
```bash
cd terraform
terraform init
terraform apply -auto-approve
```

### 2. Add GitHub Secrets
Go to GitHub repo → Settings → Secrets → Actions → New secret:

| Secret | Value |
|---|---|
| `DOCKERHUB_USERNAME` | `baigmazhar` |
| `DOCKERHUB_TOKEN` | Your DockerHub password |
| `K3S_SERVER_IP` | `3.236.189.81` |
| `K3S_KUBECONFIG` | Base64 encoded kubeconfig from K3s EC2 |

### 3. Trigger Pipeline
Push any change to `main` branch — GitHub Actions runs automatically.

### 4. Access App
- Frontend: http://3.236.189.81:30080
- Add employee data via UI — verify it persists
