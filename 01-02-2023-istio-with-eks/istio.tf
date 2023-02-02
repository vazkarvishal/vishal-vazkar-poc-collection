# resource "helm_release" "istio" {
#   namespace        = "istio-system"
#   create_namespace = true
#   name                = "istio-system"
#   repository          = "oci://public.ecr.aws/karpenter"
#   chart               = "istio-ingressgateway"
#   version             = "v0.23.0"
# }
