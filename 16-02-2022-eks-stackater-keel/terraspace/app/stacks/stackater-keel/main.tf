resource "helm_release" "stackater_reloader" {
  namespace        = "stackater"
  create_namespace = true
  name             = "stackater-reloader"
  repository       = "https://stakater.github.io/stakater-charts"
  chart            = "reloader"
  version          = "v1.0.5"
  timeout          = 120
  cleanup_on_fail  = true
  wait             = true
  lint             = true
}

resource "helm_release" "keel" {
  namespace        = "keel"
  create_namespace = true
  name             = "keel"
  repository       = "https://charts.keel.sh"
  chart            = "keel"
  # version          = "0.16.1"
  timeout         = 120
  cleanup_on_fail = true
  wait            = true
  lint            = true
  set {
    name  = "ecr.enabled"
    value = "true"
  }
  set {
    name  = "ecr.region"
    value = "ap-south-1"
  }
}

