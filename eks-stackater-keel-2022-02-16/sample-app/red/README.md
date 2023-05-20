## Docker build commands
```
# Build the app
docker build -t vish-sample:red .
# Run the app locally
docker run -it -d -p 8090:80 vish-sample:red
kubectl apply -f deployment.yaml
kubectl delete -f deployment.yaml
```