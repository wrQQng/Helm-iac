data "aws_eks_cluster" "eks" {
    name = aws_eks_cluster.eks.name
}

data "aws_eks_cluster_auth" "eks" {
    name = aws_eks_cluster.eks.name
}

provider "helm" {
  kubernetes = {
    host                   = data.aws_eks_cluster.eks.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.eks.token
  }
}

resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = "7.7.0"

  values = [
    yamlencode({
      server = {
        service = {
          type = "ClusterIP"
        }
      }
    })
  ]

  depends_on = [
    aws_eks_node_group.general
  ]
}

resource "helm_release" "prometheus" {
  name             = "prometheus"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  namespace        = "monitoring"
  create_namespace = true
  version          = "67.9.0" # фиксируйте версию

  values = [
    yamlencode({
      grafana = {
        enabled = true
        adminPassword = "${local.prometheuspass}" # Better AWS Secrets Manager
        service = {
          type = "ClusterIP"
        }
      }
      prometheus = {
        prometheusSpec = {
          retention = "7d"
          resources = {
            requests = {
              memory = "512Mi"
              cpu    = "250m"
            }
            limits = {
              memory = "1Gi"
              cpu    = "500m"
            }
          }
        }
      }
      alertmanager = {
        enabled = true
      }
    })
  ]

  depends_on = [
    aws_eks_node_group.general
  ]
}