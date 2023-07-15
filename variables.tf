variable "base_ami_filter_value" {
  description = "Filter for the base AMI"
  type        = string
  default = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
}

variable "base_ami_owner_id" {
  description = "Owner ID for the base AMI"
  type        = string
  default = "099720109477" # Canonical
}

variable "region" {
  description = "Region to run SneakyEndpoints in."
  type        = string
}