
helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo update
helm install istio-base istio/base -n istio-system
helm install istiod istio/istiod --namespace istio-system
helm install istio-ingressgateway -f ../istio-gateway-values.yaml istio/gateway --namespace istio-system