# Collection of all the commands to be used

1. Full cluster creation (including vpc)
```
eksctl create cluster --fargate --region eu-west-2 --with-oidc --without-nodegroup --asg-access --external-dns-access --full-ecr-access --alb-ingress-access -n vf-eks-poc-10
```
**Create the EKS cluster with pre-defined networks**
```
eksctl create cluster -f fargate-cluster.yaml
```

2. Setting up kubectl for the cluster - locally
```
aws eks update-kubeconfig --name 'vf-eks-poc-10'
```

3. Get Fargate Nodes
`kubectl get nodes -o wide`

4. Get pods on fargate-only deployment
`kubectl get pods --all-namespaces -o wide`


5. List OIDC associated with EKS
`aws eks describe-cluster --name vf-eks-poc-10 --query "cluster.identity.oidc.issuer" --output text`
6. List IAM Policy Associated with OIDC
`aws iam list-open-id-connect-providers | grep your_oidc_id_from_previous_command`

7. Get OIDC policy for ALB and save
`curl -o oidc_iam_policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.1.3/docs/install/iam_policy.json`

7a. Associate OIDC provider with cluster
```
eksctl utils associate-iam-oidc-provider \
    --region eu-west-2 \
    --cluster vf-eks-poc-10 \
    --approve
```

7b. Create IAM Policy
```
#Once per AWS Account - cannot create duplicate names
aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam-policy.json
```
8. Install target-group binding for AWS
```
kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller//crds?ref=master"
```

9 Install ALB ingress for Fatgate using Helm
```
helm repo add eks https://aws.github.io/eks-charts

helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
    --set clusterName=vf-eks-poc-10 \
    --set serviceAccount.create=false \
    --set region=eu-west-2 \
    --set vpcId=vpc-060857c98507e4586 \
    --set serviceAccount.name=aws-load-balancer-controller \
    -n kube-system
```

10. Create profile for the game
```
eksctl create fargateprofile --cluster vf-eks-poc-10 --region eu-west-2 --name your-alb-sample-app --namespace game-2048
```

11. Deploy the game
```
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.1.3/docs/examples/2048/2048_full.yaml

```