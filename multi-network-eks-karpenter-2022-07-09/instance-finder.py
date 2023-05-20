import os
import boto3
from re import search
import requests

ec2 = boto3.Session().client('ec2', region_name = "us-west-2")

# Get the contents of this file because currently this is the easiest way to query for a list of ec2 instance types which support branch networking
contents = requests.get("https://raw.githubusercontent.com/aws/amazon-vpc-resource-controller-k8s/master/pkg/aws/vpc/limits.go")

# Filter for instance types which support branch networking by checking if the instance has IsTrunkingCompatible=true
instanceTypes = []
for line in contents.text.splitlines():
    s = search('.*\"(.*)\":.*IsTrunkingCompatible:\s*true', line)
    if s:
        instanceTypes.append(s.group(1))

# Filter instanceTypes to only contain instance types with the nitro hypervisor. The
# InstanceTypes input to the describe_instance_types only supports an array length up
# to 100, so the instanceTypes array is split into chunks of 100 or less.
nitroInstanceTypes = []
for chunk in [instanceTypes[i:i+100] for i in range(0, len(instanceTypes), 100)]:
    paginator = ec2.get_paginator('describe_instance_types')
    page_iterator = paginator.paginate(
        InstanceTypes=chunk,
        Filters=[
            {
                'Name': 'hypervisor',
                'Values': [
                    'nitro',
                ]
            },
        ],
    )
    for page in page_iterator:
        for t in page['InstanceTypes']:
            nitroInstanceTypes.append(t['InstanceType'])

# Sort the list alphabetically
nitroInstanceTypes.sort()

# Print a list of instance types
for i in nitroInstanceTypes:
    # Calculate how many pods are supported with both Custom Networking and Prefix Delegation features enabled on the VPC CNI
    maxPods = os.popen('./max-pods-calculator.sh --cni-version 1.9.0-eksbuild.1 --cni-prefix-delegation-enabled --cni-custom-networking-enabled --instance-type ' + i).read().strip()
    # Only print instance types that support 110 pods because Karpenter currently only supports the default maxPods calculation or hard coding to 110
    if maxPods == "110":
        print(i)