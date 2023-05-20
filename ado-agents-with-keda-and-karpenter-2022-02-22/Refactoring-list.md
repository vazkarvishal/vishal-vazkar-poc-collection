# What is left to refactor?
1. Create a module for VPC which creates all our basic networking
2. Feature flagging NAT gateway and use of outbound proxy via private links
3. Create a module for subnets (public and private flags) ? TBD
4. Module for endpoints creation (generic module for creating endpoints and endpoint services)
5. Update EKS cluster name to be dynamic rather than just using the name variable as it is doing now.
6. EKS subnets - make  it dynamic to use a list of subnets passed in.
7. Update EKS Karpenter node to be fargate backed instead of EC2 nodes 
8. create spot service linked role
9. Karpenter provisioner to helm chart
10. Support EBS Encryption with CMK KMS. Currently does not work because of permissions.