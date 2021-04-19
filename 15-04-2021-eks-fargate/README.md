# EKS with Fargate PoC
EKS with Fargate only works on private subnets. You need to make sure your private subnets have access to the internet either via an outbound proxy OR a NAT gateway. Without this, the pods will fail to pull public images.

## Useful information
- [EKSCTL docs](https://eksctl.io/usage/fargate-support/)
- [Config file schema for creating manifests](https://eksctl.io/usage/schema/)
- [EKS General Commands](https://docs.aws.amazon.com/eks/latest/userguide/getting-started-eksctl.html)
- [Kubernetes Ingress](https://docs.aws.amazon.com/eks/latest/userguide/alb-ingress.html) - Uses ALB in the background.
- [EKS Cluster Management Resources](https://docs.aws.amazon.com/eks/latest/userguide/eks-managing.html)
- [AWS How to install ingress controller for fargate](https://aws.amazon.com/premiumsupport/knowledge-center/eks-alb-ingress-controller-fargate/)