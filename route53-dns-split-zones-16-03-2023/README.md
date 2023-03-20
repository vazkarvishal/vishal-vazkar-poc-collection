# Testing split zone DNS with Route53 public and private zones.

This project has been created as a playground to test split zone DNS with Route53 public and private zones. you can run the test and replace `example.com` with your Route53 zone name which you would like the app to create.

## Pre-requisite
The public hosted zone `cloud.example.com` has to exist and delegated to the AWS account from which you will be performing your tests.

```
cd terraspace
terraspace up network
terraspace down network
```

## Dependencies between stacks?
As shown on the [terraspace docs](https://terraspace.cloud/docs/dependencies/deploy-multiple/) I have had to do the following:
- create an Output in every stack which needs to be cross-referenced
- create an input in the consuming stack
- create a `base.tfvars` file in the consuming stack with the templating format and reference the previous stacks output. 

By doing the above, terraspace automatically gets cross-stack references and uses them in dependent stacks.
