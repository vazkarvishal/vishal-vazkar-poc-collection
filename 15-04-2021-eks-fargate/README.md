# EKS with Fargate PoC


## Useful information
- EKSCTL docs - https://eksctl.io/usage/fargate-support/
- Config file schema for creating manifests - https://eksctl.io/usage/schema/
- Kubernetes Ingress - https://docs.aws.amazon.com/eks/latest/userguide/alb-ingress.html (USES ALB)

## Out of the box CF template
eksctl when ran with the template in this folder and the `eksctl create cluster`
![EKS Cluster Image](eks-out-of-the-box-cf-design.png)