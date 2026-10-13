variable "region" {
  type    = string
  default = "ap-south-1"
}

variable "project" {
  type        = string
  default     = "devops-lab"
  description = "Name prefix. Also the ECR repository name, which the CI scripts expect to be devops-lab."
}

variable "instance_type" {
  type        = string
  default     = "t3.medium"
  description = "2 vCPU / 4 GiB is the minimum comfortable size for k3s + Prometheus + Grafana."
}

variable "ssh_public_key_path" {
  type    = string
  default = "~/.ssh/id_rsa.pub"
}

variable "ssh_cidr" {
  type        = string
  default     = "0.0.0.0/0"
  description = "Who may SSH. Open by default so GitHub-hosted runners can deploy; use YOUR_IP/32 when deploying from Jenkins or your laptop."
}

variable "admin_cidr" {
  type        = string
  description = "Who may open Grafana (30030) and Prometheus (30090). Use YOUR_IP/32."
}
