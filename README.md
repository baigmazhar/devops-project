# Employee Management System — DevOps Project

## Stack
| Layer | Tool |
|---|---|
| Frontend | ReactJS (served via Nginx) |
| Backend | Go (Golang 1.19) |
| Database | PostgreSQL 14 |
| Containerization | Docker |
| CI/CD | Jenkins |
| Orchestration | Kubernetes (K3s) |
| Infrastructure | Terraform (AWS EC2) |
| Cloud | AWS ap-south-1 (Mumbai) |

## Architecture
```
GitHub Push
    ↓
Jenkins (EC2 t2.medium)
    → Build Docker images
    → Push to DockerHub
    → Deploy to K3s
         ↓
K3s Kubernetes (EC2 t2.medium)
    → frontend pod  → NodePort 30080
    → backend pod   → NodePort 30800
    → postgres pod  → internal only
```

## URLs (after deployment)
- Jenkins:  http://<JENKINS_IP>:8080
- Frontend: http://<K3S_IP>:30080
- Backend:  http://<K3S_IP>:30800

## Step-by-Step Deployment

### 1. Prerequisites (already done)
- AWS CLI configured (`aws configure list`)
- Terraform installed
- Docker installed
- SSH key pair exists at `~/.ssh/id_rsa`

### 2. Generate SSH Key (if not exists)
```bash
ssh-keygen -t rsa -b 2048 -f ~/.ssh/id_rsa
```

### 3. Provision Infrastructure with Terraform
```bash
cd terraform
terraform init
terraform plan
terraform apply -auto-approve
```
Note the output IPs for Jenkins and K3s.

### 4. Wait ~5 minutes for EC2 setup scripts to finish
Then SSH in to verify:
```bash
ssh -i ~/.ssh/id_rsa ubuntu@<JENKINS_IP>
sudo systemctl status jenkins
```

### 5. Get Jenkins Initial Password
```bash
ssh -i ~/.ssh/id_rsa ubuntu@<JENKINS_IP>
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

### 6. Setup Jenkins UI
- Open http://<JENKINS_IP>:8080
- Paste initial password
- Install suggested plugins
- Create admin user

### 7. Add Jenkins Credentials
In Jenkins → Manage Jenkins → Credentials → Global → Add:

**Credential 1 — DockerHub:**
- Kind: Username with password
- ID: `dockerhub-credentials`
- Username: `baigmazhar`
- Password: your DockerHub password

**Credential 2 — K3s Kubeconfig:**
- Run locally: `./scripts/copy-kubeconfig.sh <K3S_IP>`
- Kind: Secret file
- ID: `k3s-kubeconfig`
- File: upload the generated `k3s-kubeconfig.yaml`

### 8. Add Jenkins Environment Variable
- Manage Jenkins → Configure System → Global Properties → Environment Variables
- Name: `K3S_SERVER_IP`
- Value: `<K3S_PUBLIC_IP>`

### 9. Create Jenkins Pipeline Job
- New Item → Pipeline
- Name: `employee-app-pipeline`
- Pipeline → Definition: Pipeline script from SCM
- SCM: Git
- Repository URL: `https://github.com/baigmazhar/devops-project`
- Branch: `main`
- Script Path: `Jenkinsfile`
- Save → Build Now

### 10. Access the App
- Frontend: http://<K3S_IP>:30080
- Add employees via the UI — data should persist in PostgreSQL

## DockerHub Images
- `baigmazhar/employee-backend:latest`
- `baigmazhar/employee-frontend:latest`
