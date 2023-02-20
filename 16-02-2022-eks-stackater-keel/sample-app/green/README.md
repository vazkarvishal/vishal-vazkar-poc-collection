## Docker build commands
```
# Build the app
docker build -t vish-sample:green .
# Run the app locally
docker run -it -d -p 8080:80 vish-sample:green
kubectl apply -f deployment.yaml
kubectl delete -f deployment.yaml
```

To test Stackater
- Deploy the app with `deployment.yaml` 
- update the `external-config-map.yaml` file which is the same config map but out of the initial scope of the deployment, to have different values
- Deploy the `external-config-map.yaml` using `kubectl apply -f external-config-map.yaml`
- Watch the pod getting restarted by using a tool like K9s