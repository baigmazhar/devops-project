# DevOps Project — Knowledge Base
> Employee Management System | CI/CD + Docker + Kubernetes + Terraform + AWS

---

## Project Overview

**Company:** TechVerito Software Solutions LLP  
**Task:** Implement CI/CD pipeline, containerize app with Docker, deploy on Kubernetes, infrastructure via Terraform  
**Submission Repo:** https://github.com/baigmazhar/devops-project  
**Reference App Repo:** https://github.com/TechVerito-Software-Solutions-LLP/devops-fullstack-app (DO NOT MODIFY)

---

## Application Details

| Layer | Tech | Port |
|---|---|---|
| Frontend | ReactJS (served via Nginx) | 3000 (dev) / 80 (container) |
| Backend | Go (Golang 1.19) | 8080 |
| Database | PostgreSQL 14 | 5432 (internal only) |

**App name:** Employee Management System  
**Function:** Add and view employee details (full CRUD frontend → backend → PostgreSQL)

---

## Stack

| Tool | Purpose |
|---|---|
| Docker | Containerize frontend and backend |
| Jenkins | CI/CD pipeline |
| Kubernetes (K3s) | Container orchestration |
| Terraform | AWS infrastructure as code |
| AWS | Cloud provider (Mumbai - ap-south-1) |
| DockerHub | Docker image registry |
| GitHub | Source code repository |

---

## AWS Infrastructure (Created via Terraform)

**Region:** us-east-1 (N. Virginia)  
**AWS Profile:** mazharhb  
**Resources created:** 10 (VPC, IGW, Subnet, Route Table, 2x Security Groups, Key Pair, 2x EC2)

| Resource | Value |
|---|---|
| Jenkins EC2 Public IP | `3.235.91.236` |
| Jenkins URL | `http://3.235.91.236:8080` |
| K3s EC2 Public IP | `3.236.189.81` |
| Frontend URL | `http://3.236.189.81:30080` |
| Backend URL | `http://3.236.189.81:30800` |

### SSH Commands
```bash
# SSH into Jenkins
ssh -i "C:\Users\MAZHAR\.ssh\id_rsa" ubuntu@3.235.91.236

# SSH into K3s
ssh -i "C:\Users\MAZHAR\.ssh\id_rsa" ubuntu@44.204.218.140
```

### EC2 Specs
- Instance type: `t2.medium`
- OS: Ubuntu 22.04 LTS
- Disk: 20GB gp2
- Key Pair: `devops-key` (from `C:\Users\MAZHAR\.ssh\id_rsa.pub`)

### Security Groups
**Jenkins SG:** SSH (22), Jenkins UI (8080)  
**K3s SG:** SSH (22), K3s API (6443), Frontend NodePort (30080), Backend NodePort (30800)

---

## Local Machine Setup

| Tool | Version | Status |
|---|---|---|
| AWS CLI | 2.35.11 | ✅ Configured |
| Terraform | 1.15.7 | ✅ Ready |
| Docker | 29.5.3 | ✅ Ready |
| Git | installed | ✅ Ready |
| SSH Key | RSA 2048 | ✅ `C:\Users\MAZHAR\.ssh\id_rsa` |

**AWS Configured Region:** ap-south-1  
**GitHub Username:** baigmazhar  
**DockerHub Username:** baigmazhar

---

## Project File Structure

```
devops-project/
├── backend/
│   ├── main.go                  ← Go app entry point (Fiber framework + GORM)
│   ├── go.mod / go.sum          ← Go dependencies
│   ├── controller/endpoint.go   ← HTTP handlers
│   ├── model/employee.go        ← Employee struct
│   ├── repository/repository.go ← DB queries
│   ├── routes/routes.go         ← Route registration
│   ├── service/service.go       ← Business logic
│   └── Dockerfile               ← 2-stage Go build → alpine runtime
├── frontend/
│   ├── src/App.js               ← Main React component
│   ├── src/index.js             ← React entry
│   ├── public/                  ← Static assets
│   ├── package.json             ← Node dependencies
│   ├── .env                     ← REACT_APP_SERVER_URL (overridden at build time)
│   ├── Dockerfile               ← Node build → Nginx serve (ARG for backend URL)
│   └── nginx.conf               ← Nginx config for React Router
├── k8s/
│   ├── namespace.yaml           ← Creates 'employee-app' namespace
│   ├── postgres-deployment.yaml ← PostgreSQL pod + PVC + internal Service
│   ├── backend-deployment.yaml  ← Go backend pod + NodePort 30800
│   └── frontend-deployment.yaml ← React frontend pod + NodePort 30080
├── terraform/
│   ├── main.tf                  ← VPC, subnets, SGs, 2x EC2
│   ├── variables.tf             ← Region, AMI, key path, DockerHub username
│   ├── outputs.tf               ← Prints IPs and URLs after apply
│   ├── user_data_jenkins.sh     ← Auto-installs Jenkins + Docker + kubectl on boot
│   └── user_data_k3s.sh         ← Auto-installs K3s on boot
├── scripts/
│   └── copy-kubeconfig.sh       ← Copies K3s kubeconfig to local machine
├── Jenkinsfile                  ← 5-stage CI/CD pipeline
├── README.md                    ← Deployment instructions
└── KNOWLEDGE_BASE.md            ← This file
```

---

## Kubernetes Architecture

```
Namespace: employee-app
│
├── postgres (Deployment)
│   ├── Image: postgres:14-alpine
│   ├── Port: 5432 (internal only)
│   ├── PVC: 5Gi storage
│   └── Service: postgres-service (ClusterIP)
│
├── backend (Deployment)
│   ├── Image: baigmazhar/employee-backend:latest
│   ├── Port: 8080
│   ├── Env: DB_HOST=postgres-service, DB_USER, DB_PASSWORD, DB_NAME, DB_PORT
│   └── Service: backend-service (NodePort 30800)
│
└── frontend (Deployment)
    ├── Image: baigmazhar/employee-frontend:latest
    ├── Port: 80
    └── Service: frontend-service (NodePort 30080)
```

---

## CI/CD Pipeline (Jenkinsfile)

**5 Stages:**

```
Stage 1: Checkout
  → Pulls latest code from GitHub (baigmazhar/devops-project)

Stage 2: Build Backend Docker Image
  → docker build backend/ → baigmazhar/employee-backend:latest

Stage 3: Build Frontend Docker Image
  → docker build frontend/ --build-arg REACT_APP_SERVER_URL=http://3.110.160.213:30800/employees
  → Bakes backend URL into React at build time

Stage 4: Push Images to DockerHub
  → Uses Jenkins credential: 'dockerhub-credentials'
  → Pushes both images with :BUILD_NUMBER and :latest tags

Stage 5: Deploy to Kubernetes
  → Uses Jenkins credential: 'k3s-kubeconfig' (secret file)
  → kubectl apply all k8s/ manifests
  → Rolls out new pods, waits for healthy status

Stage 6: Verify Deployment
  → kubectl get pods/services
  → Prints live URLs
```

---

## Jenkins Configuration Steps

### Step 1 — Get Initial Admin Password
```bash
ssh -i "C:\Users\MAZHAR\.ssh\id_rsa" ubuntu@13.206.253.6
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

### Step 2 — Open Jenkins UI
URL: `http://13.206.253.6:8080`
- Paste initial password
- Install suggested plugins
- Create admin user

### Step 3 — Add Credentials
Go to: Manage Jenkins → Credentials → Global → Add Credential

**Credential 1 — DockerHub:**
- Kind: `Username with password`
- ID: `dockerhub-credentials`
- Username: `baigmazhar`
- Password: DockerHub password

**Credential 2 — K3s Kubeconfig:**
- First run locally (Git Bash):
  ```bash
  ./scripts/copy-kubeconfig.sh 3.110.160.213
  ```
  This creates `k3s-kubeconfig.yaml` locally
- Kind: `Secret file`
- ID: `k3s-kubeconfig`
- File: upload `k3s-kubeconfig.yaml`

### Step 4 — Add Environment Variable
Manage Jenkins → Configure System → Global Properties → Environment Variables:
- Name: `K3S_SERVER_IP`
- Value: `3.110.160.213`

### Step 5 — Create Pipeline Job
- New Item → Pipeline
- Name: `employee-app-pipeline`
- Pipeline → Definition: `Pipeline script from SCM`
- SCM: `Git`
- Repository URL: `https://github.com/baigmazhar/devops-project`
- Branch: `main`
- Script Path: `Jenkinsfile`
- Save → Build Now

---

## DockerHub Images

| Image | URL |
|---|---|
| Backend | `docker.io/baigmazhar/employee-backend:latest` |
| Frontend | `docker.io/baigmazhar/employee-frontend:latest` |

---

## Backend Environment Variables

| Variable | Value in K8s |
|---|---|
| DB_HOST | `postgres-service` |
| DB_USER | `postgres` |
| DB_PASSWORD | `postgres123` |
| DB_NAME | `employeedb` |
| DB_PORT | `5432` |
| ALLOWED_ORIGINS | `*` |

---

## Key Commands Reference

### Terraform
```powershell
cd E:\Python\tech-verito\devops-project\terraform
terraform init       # download providers
terraform plan       # preview changes
terraform apply      # create infrastructure
terraform destroy    # destroy everything (careful!)
```

### Check EC2 Setup Logs
```bash
# Check if Jenkins installed correctly
ssh -i "C:\Users\MAZHAR\.ssh\id_rsa" ubuntu@13.206.253.6 "sudo cat /var/log/user_data.log"

# Check if K3s installed correctly
ssh -i "C:\Users\MAZHAR\.ssh\id_rsa" ubuntu@3.110.160.213 "sudo cat /var/log/user_data.log"
```

### Kubernetes Commands (run on K3s EC2 or via Jenkins)
```bash
kubectl get pods -n employee-app
kubectl get services -n employee-app
kubectl get deployments -n employee-app
kubectl logs deployment/backend -n employee-app
kubectl logs deployment/frontend -n employee-app
kubectl describe pod <pod-name> -n employee-app
```

### Copy Kubeconfig (Git Bash on Windows)
```bash
./scripts/copy-kubeconfig.sh 3.110.160.213
```

---

## Submission Deliverables

| Item | Value |
|---|---|
| Jenkins URL | `http://3.235.91.236:8080` |
| Frontend App URL | `http://3.236.189.81:30080` |
| Backend API URL | `http://3.236.189.81:30800` |
| GitHub Repo | `https://github.com/baigmazhar/devops-project` |
| DockerHub | `https://hub.docker.com/u/baigmazhar` |
| Dockerfile (backend) | `backend/Dockerfile` |
| Dockerfile (frontend) | `frontend/Dockerfile` |

---

## Progress Tracker

- [x] Analyzed TechVerito sample app (Go backend + React frontend + PostgreSQL)
- [x] Created project structure in devops-project repo
- [x] Written backend Dockerfile (2-stage Go build)
- [x] Written frontend Dockerfile (Node build + Nginx serve, with ARG for backend URL)
- [x] Written Nginx config for React Router
- [x] Written Terraform (VPC, 2x EC2, security groups, key pair)
- [x] Written K8s manifests (namespace, postgres, backend, frontend)
- [x] Written Jenkinsfile (5-stage pipeline)
- [x] Generated SSH key pair
- [x] Ran terraform apply — 10 resources created on AWS (mazharhb account, us-east-1)
- [x] Switched CI/CD from Jenkins to GitHub Actions
- [x] Fixed DockerHub username (mazharbaig)
- [x] Fixed K3s TLS certificate to accept public IP
- [x] Upgraded K3s EC2 to t3.small (2GB RAM)
- [x] New K3s IP: 98.81.102.19
- [x] Pipeline ran successfully — 1 min 4 sec
- [x] App is LIVE at http://98.81.102.19:30080
- [x] Employees can be added and viewed ✅
- [x] PROJECT COMPLETE ✅
