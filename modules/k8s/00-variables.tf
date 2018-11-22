variable "region" {
  description = "The region to deploy the cluster in, e.g: eu-west-1. Note that this *must* be a region with at least 3 availability zones"
  default = "eu-west-1"
}

variable "azs" {
  description = "Availability Zones for this region"
  type = "list"
  default = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
}

variable "stackname" {
  description = "Name of the k8s stack"
}

variable "master_instance_type" {
  description = "The size of the master nodes, e.g: t2.large. Note that k8s will probably not run on anything smaller than t2.large"
}

variable "master_api_port" {
  description = "The K8S API port"
  default     = 443
}

variable "master_health_target" {
  description = "The health api endpoint for the master node"
  default     = "TCP:443"
}

variable "node_instance_type" {
  description = "The size of the infrastructure nodes, e.g: m4.xlarge. Note that these need to be at least t2.xlarge for logging and monitoring to work as well"
}

variable "app_instance_type" {
  description = "The size of the application/worker nodes, e.g. t2.xlarge"
}

variable "app_node_count" {
  description = "The number of application/worker nodes, e.g. 3. These will be equally distributed along the AZs"
}

variable "master_node_count" {
  description = "The number of master nodes, e.g. 3. These will be equally distributed along the AZs"
}

variable "infra_node_count" {
  description = "The number of infra nodes, e.g. 3. These will be equally distributed along the AZs"
}

variable "vpc_name" {
  description = "The name for the VPC"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC, e.g: 10.0.0.0/16"
}

variable "public_subnet_cidr_list" {
  description = "The 3 CIDR blocks for the public subnets, e.g: 10.15.1.0/24,10.15.2.0/24,10.15.3.0/24"
  type = "list"
  default = ["10.15.1.0/24", "10.15.2.0/24", "10.15.3.0/24"]
}

variable "private_subnet_cidr_list" {
  description = "The 3 CIDR blocks for the private subnets, e.g: 10.15.4.0/24,10.15.5.0/24,10.15.6.0/24"
  type = "list"
  default = ["10.15.4.0/24", "10.15.5.0/24", "10.15.6.0/24"]
}

variable "calico_pod_cidr" {
  description = "The network CIDR to use for Calico overlay network"
  default = "192.168.0.0/16"
}

variable "key_name" {
  description = "The name of the key to user for ssh access, e.g: k8s-key"
}

variable "public_key_path" {
  description = "The local public key path, e.g. ~/.ssh/k8s-key.pub"
}

variable "public_hosted_zone" {
  description = "The name of the Route53 hosted zone to create DNS records"
}

variable "app_dns_prefix" {
  description = "DNS prefix to be used for applications deployed on the cluster"
}
