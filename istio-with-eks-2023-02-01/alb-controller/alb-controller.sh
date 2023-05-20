curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.4.4/docs/install/iam_policy.json
aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam_policy.json
    
#  Grant ec2:DescribeAvailabilityZones to the ALB role
# Tags on subnets should be available kubernetes.io/role/internal-elb: 1 for internal subnets
# Tags on subnets should be available kubernetes.io/role/elb: 1 for public subnets
