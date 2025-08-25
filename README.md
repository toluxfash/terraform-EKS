# EKS Infrastructure Deployment (Terraform + Helm)

This project provisions a production-ready **AWS EKS cluster** with supporting infrastructure using **Terraform** and deploys essential Kubernetes components with **Helm**.  
It includes auto-scaling nodes, metrics-server, cluster-autoscaler, AWS Load Balancer Controller, and sample applications (`app1` and `app2`).

---

## 📌 Architecture Overview

The infrastructure is composed of the following components:

- **VPC & Subnets**
  - Main VPC (`10.0.0.0/16`)
  - 2 Public subnets for NAT/ALB
  - 2 Private subnets for EKS nodes
  - Route tables, NAT gateway, and Internet Gateway

- **EKS Cluster**
  - Managed EKS cluster with IAM role and version `1.33`
  - Node group with on-demand EC2 instances (`c7i-flex.large`)
  - Auto-scaling enabled

- **IAM Roles & Policies**
  - Cluster role and node role with required EKS policies
  - AWS Load Balancer Controller role
  - Cluster Autoscaler role with pod identity association

- **Helm Deployed Components**
  - Metrics Server (`metrics-server`)
  - Cluster Autoscaler
  - AWS Load Balancer Controller

- **Sample Applications**
  - `app1` deployed with HPA
  - `app2` exposed via NLB LoadBalancer

---

## 📂 Project Structure

```bash
terraform-eks/
├── app1/                    # Sample app 1 Kubernetes manifests
│   ├── deployment.yaml
│   ├── hpa.yaml
│   ├── namespace.yaml
│   └── service.yaml
├── app2/                    # Sample app 2 Kubernetes manifests
│   ├── deployment.yaml
│   ├── namespace.yaml
│   └── svc.yaml
├── eks.tf                   # EKS cluster IAM & resource definitions
├── node.tf                  # Node group IAM & resource definitions
├── vpc.tf                   # VPC resource
├── subnet.tf                # Subnets
├── routes.tf                # Route tables & associations
├── igw.tf                   # Internet Gateway
├── nat.tf                   # NAT gateway & EIP
├── helm-provider.tf         # Kubernetes & Helm providers
├── metrics-server.tf        # Helm deployment of metrics-server
├── cluster-autoscaler.tf    # Helm deployment of cluster autoscaler
├── pod-identity-addon.tf    # EKS Pod Identity Addon
├── aws-lbc.tf               # AWS Load Balancer Controller
├── locals.tf                # Local variables
├── provider.tf              # Terraform AWS provider
├── iam/                     # IAM policies
│   └── AWSLoadBalancerController.json
├── terraform.tfstate        # Terraform state (local)
├── terraform.tfstate.backup
├── values/                  # Helm values files
│   └── metrics-server.yaml
└── wget-log
```

# ⚡ Prerequisites

- Terraform v1.5.0 or later
- AWS Account with permissions for:
- EC2, IAM, VPC, EKS, S3, ALB, CloudWatch
- SSH Key Pair (optional if using bastion or nodes)

# 🔧 Usage

1. Clone this repository:
    ```bash
    git clone <repo-url>
    cd terraform-eks
2. Initialize Terraform:
    ```bash
    terraform init
3. Review the execution plan:
    ```bash
    terraform plan
4. Apply Terraform changes:
    ```bash
    terraform apply
5. Deploy sample applications:
    kubectl apply -f app1/
    kubectl apply -f app2/
6. Destroy resources when no longer needed:
    ```bash
    terraform destroy

# 🔒 Notes

- Terraform state is stored locally (terraform.tfstate) — consider using S3 backend + DynamoDB for collaboration.
- IAM roles created have broad permissions — restrict in production.
- app2 uses AWS NLB via svc.yaml annotations.

# 📖 Next Steps

- Add monitoring (CloudWatch / Prometheus)
- Integrate CI/CD pipeline (GitHub Actions / GitLab CI)
- Implement additional EKS addons (Ingress controllers, security policies)
- Migrate Terraform state to remote backend for team collaboration

# 🧑‍💻 Author

DevOps Engineer(toluxfash) — AWS EKS Project

graph TD
    Internet -->|HTTP/SSH| IGW[Internet Gateway]
    IGW --> PublicSubnets[Public Subnets]
    PublicSubnets --> NAT[NAT Gateway]
    PublicSubnets --> EKS[EKS Cluster]

    subgraph PrivateSubnets
        Nodes[Node Group EC2 Instances]
    end

    EKS --> Nodes
    Nodes --> Metrics[Metrics Server]
    Nodes --> Autoscaler[Cluster Autoscaler]
    Nodes --> LBC[AWS Load Balancer Controller]
    Nodes --> App1[App1]
    Nodes --> App2[App2]

    subgraph VPC
        PublicSubnets
        PrivateSubnets
        NAT
    end
