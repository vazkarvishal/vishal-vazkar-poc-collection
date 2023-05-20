eksctl create iamserviceaccount \
  --cluster=karpenter-demo \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --role-name AmazonEKSLoadBalancerControllerRole \
  --attach-policy-arn=arn:aws:iam::{{your-aws-account-number}}:policy/AWSLoadBalancerControllerIAMPolicy \
  --approve