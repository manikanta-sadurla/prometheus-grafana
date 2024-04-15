terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0.0"
    }

    kubernetes = {
        version = ">= 2.0.0"
        source = "hashicorp/kubernetes"
    }

    kubectl = {
      source = "gavinbunney/kubectl"
      version = "1.14.0"
    }

    grafana = {
      source  = "grafana/grafana"
      version = "2.17.0"
    }
  }
}

provider "grafana" {
  url  = "http://ad27eaa0135f14bf7996d14742a7daac-492242471.us-east-1.elb.amazonaws.com/login"
  auth = "admin:prom-operator"
}

data "aws_eks_cluster" "ClusterName" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "ClusterName_auth" {
  name = var.cluster_name
}

provider "aws" {
  region = var.region
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "kubectl" {
  load_config_file         = false
  host                     = data.aws_eks_cluster.ClusterName.endpoint
  cluster_ca_certificate   = base64decode(data.aws_eks_cluster.ClusterName.certificate_authority[0].data)
  token                    = data.aws_eks_cluster_auth.ClusterName_auth.token
  config_path              = "~/.kube/config"
}

resource "time_sleep" "wait_for_kubernetes" {
  create_duration = "20s"
}

resource "kubernetes_namespace" "kube-namespace" {
  metadata {
    name = "prometheus"
  }
}

resource "helm_release" "prometheus" {
  name              = "prometheus"
  repository        = "https://prometheus-community.github.io/helm-charts"
  chart             = "kube-prometheus-stack"
  namespace         = kubernetes_namespace.kube-namespace.id
  create_namespace  = true
  version           = var.helm_chart_version
  timeout           = 2000

  set {
    name  = "podSecurityPolicy.enabled"
    value = true
  }

  set {
    name  = "server.persistentVolume.enabled"
    value = false
  }

  # You can provide a map of value using yamlencode. Don't forget to escape the last element after point in the name
  set {
    name  = "server\\.resources"
    value = yamlencode({
      limits = {
        cpu    = "200m"
        memory = "50Mi"
      }
      requests = {
        cpu    = "100m"
        memory = "30Mi"
      }
    })
  }
}

### Deploy BlackBox Exporter 
resource "helm_release" "blackbox_exporter" {
  depends_on = [kubernetes_namespace.kube-namespace, time_sleep.wait_for_kubernetes]
  name       = "blackbox-exporter"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus-blackbox-exporter"
  namespace  = kubernetes_namespace.kube-namespace.id
  create_namespace = false

  values = [
    file("blackbox_values.yaml")
  ]
}

# resource "grafana_dashboard" "endpoint_monitoring_dashboard" {
#   depends_on = [helm_release.prometheus, helm_release.blackbox_exporter]

#   config_json = jsonencode({
#   "dashboard": {
#     "id": null,
#     "title": "Endpoint Monitoring Dashboard",
#     "panels": [
#       {
#         "title": "Google Health",
#         "type": "graph",
#         "datasource": "Prometheus",
#         "targets": [
#           {
#             "expr": "probe_success{job=\"blackbox\", instance=\"https://www.google.com/\"}"
#           }
#         ],
#         "legend": {
#           "show": false
#         }
#       },
#       {
#         "title": "Gmail Health",
#         "type": "graph",
#         "datasource": "Prometheus",
#         "targets": [
#           {
#             "expr": "probe_success{job=\"blackbox\", instance=\"https://www.gmail.com/\"}"
#           }
#         ],
#         "legend": {
#           "show": false
#         }
#       }
#     ],
#     "schemaVersion": 22,
#     "version": 0
#   },
#   "overwrite": true
# }
# )
# }
