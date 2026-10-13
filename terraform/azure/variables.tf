variable "subscription_id" {
  type        = string
  description = "az account show --query id -o tsv"
}

variable "location" {
  type    = string
  default = "eastus"
}

variable "project" {
  type    = string
  default = "devops-lab"
}

variable "vm_size" {
  type        = string
  default     = "Standard_B2s"
  description = "2 vCPU / 4 GiB. If unavailable in your region/subscription, check: az vm list-skus -l <region> --size Standard_B2 -o table"
}

variable "ssh_public_key_path" {
  type    = string
  default = "~/.ssh/id_rsa.pub"
}

variable "ssh_cidr" {
  type    = string
  default = "*"
}

variable "admin_cidr" {
  type        = string
  description = "Who may open Grafana and Prometheus. Use YOUR_IP/32."
}
