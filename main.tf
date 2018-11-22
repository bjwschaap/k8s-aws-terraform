//  Setup the core provider information. You can provide your credentials via
//  the AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY environment variables,
//  representing your AWS Access Key and AWS Secret Key, respectively.
provider "aws" {
  region  = "${var.region}"
}

//  Create the Kubernetes cluster using our module.
module "k8s" {
  region                   = "${var.region}"
  azs                      = "${var.azs}"
  source                   = "./modules/k8s"
  stackname                = "${var.stackname}"
  master_instance_type     = "t2.xlarge"
  node_instance_type       = "t2.xlarge"
  app_instance_type        = "t2.large"
  app_node_count           = 3
  master_node_count        = 3
  infra_node_count         = 3
  vpc_name                 = "${var.stackname}-vpc"
  vpc_cidr                 = "10.20.0.0/16"
  public_subnet_cidr_list  = ["10.20.1.0/24", "10.20.2.0/24", "10.20.3.0/24"]
  private_subnet_cidr_list = ["10.20.4.0/24", "10.20.5.0/24", "10.20.6.0/24"]
  key_name                 = "AWS-EC2-key"
  public_key_path          = "${var.public_key_path}"
  public_hosted_zone       = "dev.schaap.cc"
  app_dns_prefix           = "app"
}

//  Output some useful variables for quick SSH access etc.
output "bastion-public_dns" {
  value = "${module.k8s.bastion-public_dns}"
}
output "bastion-public_ip" {
  value = "${module.k8s.bastion-public_ip}"
}
output "master-url" {
  value = "${module.k8s.master-public_dns}"
}
