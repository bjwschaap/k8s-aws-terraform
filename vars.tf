// Default region where to create our cluster
variable "region" {
  description = "The region where the cluster must be created"
  default = "eu-west-1"
}

variable "azs" {
  description = "The availability zones within the region"
  default = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
}

// The name we should use for our cluster, and base our resource names on
variable "stackname" {
  description = "The name to use for the created cluster"
  default = "k8s"
}

//  The public key to use for SSH access.
variable "public_key_path" {
  default = "~/.ssh/aws_ec2_key.pub"
}
