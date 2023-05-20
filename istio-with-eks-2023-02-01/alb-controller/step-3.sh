helm repo add eks https://aws.github.io/eks-charts

helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=karpenteter-demo \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller