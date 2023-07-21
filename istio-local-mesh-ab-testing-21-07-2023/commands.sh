helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo update
kubectl create namespace istio-system
helm install istio-base istio/base -n istio-system --set defaultRevision=default
helm install istiod istio/istiod -n istio-system --wait
helm ls -n istio-system
kubectl get deployments -n istio-system --output wide
kubectl create namespace istio-ingress
helm install istio-ingress istio/gateway -n istio-ingress --wait

kubectl label namespace default istio-injection=enabled

export INGRESS_NAME=istio-ingressgateway
export INGRESS_NS=istio-system

kubectl apply -f booking-info-sample.yaml
kubectl apply -f destination-rules.yaml
kubectl apply -f istio-gateway.yaml
kubectl apply -f virtual-service.yaml

# Commands to delete

kubectl delete -f booking-info-sample.yaml
kubectl delete -f destination-rules.yaml
kubectl delete -f istio-gateway.yaml
kubectl delete -f virtual-service.yaml

helm delete istio-ingress -n istio-ingress
kubectl delete namespace istio-ingress
helm delete istiod -n istio-system
helm delete istio-base -n istio-system
kubectl delete namespace istio-system

