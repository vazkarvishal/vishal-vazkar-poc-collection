# Installs CRDs needed by istio to run
resource "helm_release" "istio_base" {
  name       = "istio-base"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "base"
  version    = "v1.16.2"

  namespace        = "istio-system"
  create_namespace = true
  timeout          = 180
  force_update     = true
  recreate_pods    = true
  max_history      = 10
  wait             = true
  wait_for_jobs    = true
  lint             = true
  cleanup_on_fail  = true

}


# Installs istio daemon
resource "helm_release" "istiod" {
  name       = "istiod"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "istiod"
  version    = "v1.16.2"
  namespace  = "istio-system"

  create_namespace = true
  timeout          = 180
  force_update     = true
  recreate_pods    = true
  max_history      = 10
  wait             = true
  wait_for_jobs    = true
  lint             = true
  cleanup_on_fail  = true
  set {
    name  = "meshConfig.accessLogFile"
    value = "/dev/stdout"
  }

  depends_on = [helm_release.istio_base]
}

# Creates istio-ingress service that controls traffic coming inside the mesh
resource "helm_release" "istio_gateway_deployment" {
  name       = "istio-ingress-gateway-deployment"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "gateway"
  version    = "v1.16.2"

  namespace        = "istio-system"
  create_namespace = true
  timeout          = 180
  force_update     = true
  recreate_pods    = true
  max_history      = 10
  wait             = true
  wait_for_jobs    = true
  lint             = true
  cleanup_on_fail  = true
  depends_on       = [helm_release.istiod]

  set {
    name  = "service.type"
    value = "NodePort"
  }

}

resource "kubectl_manifest" "istio_gateway_resource-pip" {
  yaml_body = <<-YAML
    apiVersion: networking.istio.io/v1alpha3
    kind: Gateway
    metadata:
      name: pip
      namespace: istio-system
    spec:
      selector:
        istio: ingress-gateway-deployment   # This should match the istio: <istio-ingress-gateway-name> label
      servers:
        - port:
            number: 80
            name: http
            protocol: HTTP
          hosts:
            - "*"
  YAML

  depends_on = [
    helm_release.istio_gateway_deployment
  ]
}

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
