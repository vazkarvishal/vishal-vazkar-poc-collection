resource "helm_release" "istio_base" {
  namespace        = "istio-system"
  create_namespace = true
  name             = "istio-base"
  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = "base"
  version          = "v1.16.2"
  timeout          = 120
  cleanup_on_fail  = true
  wait             = true
  lint             = true
}

resource "helm_release" "istiod" {
  namespace        = "istio-system"
  create_namespace = true
  name             = "istiod"
  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = "istiod"
  version          = "v1.16.2"
  timeout          = 120
  cleanup_on_fail  = true
  wait             = true
  lint             = true
  set {
    name  = "sidecarInjectorWebhook.enableNamespacesByDefault"
    value = "true"
  }
  depends_on = [
    helm_release.istio_base
  ]
}

resource "kubectl_manifest" "istio_gateway_namespace" {
  yaml_body = <<-YAML
    apiVersion: v1
    kind: Namespace
    metadata:
      name: istio-ingressgateway
      labels:
        istio-injection: enabled
  YAML
  depends_on = [
    helm_release.istiod
  ]
}

resource "helm_release" "istio_ingress_gateway" {
  namespace        = kubectl_manifest.istio_gateway_namespace.namespace
  create_namespace = true
  name             = "istio-ingressgateway"
  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = "gateway"
  version          = "v1.16.2"
  timeout          = 120
  cleanup_on_fail  = true
  max_history      = 5
  wait             = true
  lint             = true
  set {
    name  = "service.type"
    value = "NodePort"
  }
  depends_on = [kubectl_manifest.istio_gateway_namespace]
}

# resource "kubectl_manifest" "istio_gateway_resource-pip" {
#   yaml_body = <<-YAML
#     apiVersion: networking.istio.io/v1alpha3
#     kind: Gateway
#     metadata:
#       name: pip
#       namespace: istio-system
#     spec:
#       selector:
#         istio: ingress-gateway-deployment   # This should match the istio: <istio-ingress-gateway-name> label
#       servers:
#         - port:
#             number: 80
#             name: http
#             protocol: HTTP
#           hosts:
#             - "*"
#   YAML

#   depends_on = [
#     helm_release.istio_gateway_deployment
#   ]
# }

# resource "helm_release" "kiali_operator_deployment" {
#   name       = "kiali-operator-deployment"
#   repository = "https://kiali.org/helm-charts"
#   chart      = "kiali-operator"
#   version    = "v1.63.1 "

#   namespace        = "kiali-operator"
#   create_namespace = true
#   timeout          = 180
#   force_update     = true
#   recreate_pods    = true
#   max_history      = 10
#   wait             = true
#   wait_for_jobs    = true
#   lint             = true
#   cleanup_on_fail  = true
#   depends_on       = [helm_release.istio_gateway_deployment]

#   set {
#     name  = "cr.create"
#     value = "true"
#   }

#   set {
#     name  = "cr.namespace"
#     value = "istio-system"
#   }

#   set {
#     name  = "auth.strategy"
#     value = "anonymous"
#   }

# }
