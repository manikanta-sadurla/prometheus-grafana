# terraform {
#   required_providers {
#     helm = {
#       source  = "hashicorp/helm"
#       version = ">= 2.0.0"
#     }

#     kubernetes = {
#         version = ">= 2.0.0"
#         source = "hashicorp/kubernetes"
#     }

#     kubectl = {
#       source = "gavinbunney/kubectl"
#       version = "1.14.0"
#     }
#   }
# }

# # resource "null_resource" "update_kubeconfig" {
# #   provisioner "local-exec" {
# #     command = "aws eks --region us-east-1 update-kubeconfig --name arc-poc-sl-k8s-cluster"
# #   }
# # }


# data "aws_eks_cluster" "ClusterName" {
#   name = "arc-poc-sl-k8s-cluster"
# }
# data "aws_eks_cluster_auth" "ClusterName_auth" {
#   name = "arc-poc-sl-k8s-cluster"
# }


# provider "aws" {
#   region     = "us-east-1"
# }


# provider "helm" {
#     kubernetes {
#       config_path = "~/.kube/config"
#     #   depends_on = [null_resource.update_kubeconfig]
#     }
# }


# provider "kubernetes" {
#   config_path = "~/.kube/config"
# }

# provider "kubectl" {
#    load_config_file = false
#    host                   = data.aws_eks_cluster.ClusterName.endpoint
#    cluster_ca_certificate = base64decode(data.aws_eks_cluster.ClusterName.certificate_authority[0].data)
#    token                  = data.aws_eks_cluster_auth.ClusterName_auth.token
#     config_path = "~/.kube/config"
#     }



# #main


# data "aws_eks_node_group" "eks-node-group" {
#   cluster_name = "arc-poc-sl-k8s-cluster"
#   node_group_name = "arc-poc-sl-k8s-workers"
# }

# resource "time_sleep" "wait_for_kubernetes" {

#     depends_on = [
#         data.aws_eks_cluster.ClusterName
#     ]

#     create_duration = "20s"
# }

# resource "kubernetes_namespace" "kube-namespace" {
#   depends_on = [data.aws_eks_node_group.eks-node-group, time_sleep.wait_for_kubernetes]
#   metadata {
    
#     name = "prometheus"
#   }
# }

# resource "helm_release" "prometheus" {
#   depends_on = [kubernetes_namespace.kube-namespace, time_sleep.wait_for_kubernetes]
#   name       = "prometheus"
#   repository = "https://prometheus-community.github.io/helm-charts"
#   chart      = "kube-prometheus-stack"
#   namespace  = kubernetes_namespace.kube-namespace.id
#   create_namespace = true
#   version    = "45.7.1"
#   values = [
#     file("values.yaml")
#   ]
#   timeout = 2000
  

# set {
#     name  = "podSecurityPolicy.enabled"
#     value = true
#   }

#   set {
#     name  = "server.persistentVolume.enabled"
#     value = false
#   }

#   # You can provide a map of value using yamlencode. Don't forget to escape the last element after point in the name
#   set {
#     name = "server\\.resources"
#     value = yamlencode({
#       limits = {
#         cpu    = "200m"
#         memory = "50Mi"
#       }
#       requests = {
#         cpu    = "100m"
#         memory = "30Mi"
#       }
#     })
#   }
# }

