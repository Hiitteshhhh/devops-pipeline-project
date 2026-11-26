# DevOps Pipeline Project

A production-grade CI/CD pipeline deploying a Python Flask REST API to AWS ECS Fargate.

## Architecture
- **App:** Python Flask REST API with Gunicorn
- **Containerization:** Docker with multi-stage build
- **Infrastructure:** AWS ECS Fargate, ECR, S3, IAM (provisioned with Terraform)
- **CI/CD:** GitHub Actions — auto build, push, deploy on every commit
- **Config Management:** Ansible playbook for deployment verification
- **Monitoring:** AWS CloudWatch dashboard + CPU alerts

## Pipeline Flow
git push → GitHub Actions → Docker build → ECR push → ECS deploy → Ansible verify → CloudWatch monitor

## Live Endpoints
- GET /         — API info
- GET /health   — Health check
- GET /info     — Container info

## Tools Used
Docker, Python, Flask, Terraform, Ansible, AWS ECS, AWS ECR, GitHub Actions, CloudWatch