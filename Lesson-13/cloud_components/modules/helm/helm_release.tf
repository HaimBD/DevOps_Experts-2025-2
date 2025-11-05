provider "helm" {
  kubernetes {
    host                   = var.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
    }
  }
}

resource "helm_release" "flask_app" {
  name       = "ai-lab"
  chart      = "${path.module}/../../flask_app/helm"
  namespace  = "default"
  timeout    = 300
  wait       = true

  values = [file("${path.module}/values.yaml")]
}