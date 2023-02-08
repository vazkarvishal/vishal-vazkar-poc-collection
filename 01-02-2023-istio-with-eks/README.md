# Testing Istio Service Mesh capabilities with EKS

This project has been created as a playground to test Istio with EKS. I am also making use of [Terraspace](https://terraspace.cloud/) to provision the stacks, as I wanted to play around with the tool and experience the benefit of using it over vanilla Terraform. Mainly using commands like the ones mentioned below within the `terraspace` folder.

```
terraspace all up
terraspace all down
terraspace up network
terraspace down network
terraspace up eks
terraspace down eks
terraspace up karpenter
terraspace down karpenter
terraspace up istio
terraspace down istio
```