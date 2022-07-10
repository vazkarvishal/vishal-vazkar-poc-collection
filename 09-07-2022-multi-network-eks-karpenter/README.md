
## Karpenter and EKS bootstrapped from the [Karpenter website](https://karpenter.sh/v0.13.2/getting-started/getting-started-with-terraform/)

Follow the above bootstrap guide to get the basic cluster setup with Karpenter.

## Steps to create
1. Terraform deployment
2. Inflate deployment to test (edit inflate.yaml to have more replicas)
3. View the `user-data` of the Karpenter provisioned node after it gets provisioned. should have the `max-pods` value set. Without this parameter being set correctly on the controller, the `max-pods` setting on `user-data` will be missing.
4. Get the aws-node daemonset using `kubectl get ds -n kube-system aws-node -o yaml > aws-node-daemonset.yaml`. I have not committed this file due to sensitive information being present in the response.
5. Modify/add the below values:
```yaml
- name: AWS_VPC_K8S_CNI_CUSTOM_NETWORK_CFG
  value: "true"
- name: ENI_CONFIG_LABEL_DEF
  value: "topology.kubernetes.io/zone"
``` 
6. Apply the daemonset config using `kubectl apply -f aws-node-daemonset.yaml`
7. Terminate the EC2 and re-provision it
8. Apply ENI CRD using `kubectl apply -f eni-config-crd.yaml`
9. Apply ENI configs using the below:
```yaml
# Update the vaules to match the cluster SG and Subnets created for your cluster.
kubectl apply -f eni-config-az1.yaml
kubectl apply -f eni-config-az2.yaml
kubectl apply -f eni-config-az3.yaml
```
10. Following the [aws docs](https://docs.aws.amazon.com/eks/latest/userguide/cni-increase-ip-addresses.html) to enable prefix delegation on our EC2s, as AWS recommends, check if you have the 1.10+ version of EKS CNI by running `kubectl describe daemonset aws-node --namespace kube-system | grep Image | cut -d "/" -f 2`
11. If the output of the above command is 1.10 and above, please proceed. Else, referr to the doc which I have linked above.
12. Update the `aws-node-daemonset.yaml` file (I have done this already) and change `ENABLE_PREFIX_DELEGATION` to `true` and apply the daemonset using `kubectl apply -f aws-node-daemonset.yaml`

## Test

Now that everything has been configured, it is time to test!

1. Reduce the inflate pod CPU footprint to a really low value (0.05 in my case)
2. Scale the inflate deployment to 120. This should ideally provision 110 pods on 1 EC2 and then scale out to another instance.
3. Repeate the same and scale inflate out to 220. You should not observe any scaling.
4. Scale further out to 230. A new EC2 should be provisioned.

## Test 2 - Small EC2 test for prefix delegation (AND TEST Karpenter Limitation)
We want to make sure prefix delegation is working as expected. In this case, we will now limit Karpenter to provision only t3.micro instances. I have already added the requirement in our `karpenter-helm.tf`.
1. Scale inflate out to 25
2. Observe. The t3 should be able to host 18 pods each node. (Some pods may go on worker due to the nature of this setup, thus setting the value to 25 rather than 17)
3. Once you see the instance with 18 pods, increase by 1. At this time, karpenter will try to provision the pod **wrongly** on the instance due to not knowing the ENI loss due to custom networking. This will leave our pod in an unstable state.