# Collection of all the commands to be used

1. Create the EKS cluster
```
eksctl create cluster -f fargate-cluster.yaml
```

2. Setting up kubectl for the cluster
```
aws eks update-kubeconfig --name 'vv-fargate-poc'
```