## Docker build commands
```
# Build the app
docker build -t vish-sample:green .
# Run the app locally
docker run -it -d -p 8080:80 vish-sample:green
kubectl apply -f deployment.yaml
kubectl delete -f deployment.yaml
```

## To test Stackater
- Push the docker image built locally to the ECR created as a part of this repo named `sample_app_ecr`. You can do this by using the following commands:
```
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
docker tag vish-sample:green AWS_ACCOUNT_ID.dkr.ecr.AWS_REGION.amazonaws.com/sample_app_ecr:latest
docker push vish-sample:green AWS_ACCOUNT_ID.dkr.ecr.AWS_REGION.amazonaws.com/sample_app_ecr:latest
```
- Deploy the app with `deployment.yaml` 
- update the `external-config-map.yaml` file which is the same config map but out of the initial scope of the deployment, to have different values
- Deploy the `external-config-map.yaml` using `kubectl apply -f external-config-map.yaml`
- Watch the pod getting restarted by using a tool like K9s

## To test Keel
- Push the docker image built locally to the ECR created as a part of this repo named `sample_app_ecr`. You can do this by using the following commands:
```
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
docker tag vish-sample:green AWS_ACCOUNT_ID.dkr.ecr.AWS_REGION.amazonaws.com/sample_app_ecr:latest
docker push vish-sample:green AWS_ACCOUNT_ID.dkr.ecr.AWS_REGION.amazonaws.com/sample_app_ecr:latest
```
- Deploy the app with the `deployment.yaml` file. 
- Watch Keel logs using a tool like K9s and watch the ECR Repo getting added to the watch list
- Annotations on the `deployment.yaml` file define how frequently the repo is polled. For the purpose of this example, I have made polling very aggressive (10 seconds).
- Now re-tag the latest ECR to use the red docker image built locally from `sample-app/red` folder.
- Use the below commands:
```
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
docker tag vish-sample:red AWS_ACCOUNT_ID.dkr.ecr.AWS_REGION.amazonaws.com/sample_app_ecr:latest
docker push vish-sample:red AWS_ACCOUNT_ID.dkr.ecr.AWS_REGION.amazonaws.com/sample_app_ecr:latest
```
- Watch the pod getting restarted automatically by Keel and remove the old pod gracefully.