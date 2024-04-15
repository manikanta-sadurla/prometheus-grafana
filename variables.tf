variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}

variable "node_group_name" {
  description = "The name of the node group"
  type        = string
}

variable "region" {
  description = "The AWS region"
  type        = string
}

variable "helm_chart_version" {
  description = "The version of the Helm chart"
  type        = string
}
