# EKS with Fargate PoC
EKS with Fargate only works on private subnets. You need to make sure your private subnets have access to the internet either via an outbound proxy OR a NAT gateway. Without this, the pods will fail to pull public images.

## Useful information
- [EKSCTL docs](https://eksctl.io/usage/fargate-support/)
- [Config file schema for creating manifests](https://eksctl.io/usage/schema/)
- [EKS General Commands](https://docs.aws.amazon.com/eks/latest/userguide/getting-started-eksctl.html)
- [Kubernetes Ingress](https://docs.aws.amazon.com/eks/latest/userguide/alb-ingress.html) - Uses ALB in the background.

## Out of the box CF template
eksctl when ran with the template in this folder and the `eksctl create cluster`
![EKS Cluster Image](eks-out-of-the-box-cf-design.png)