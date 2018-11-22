# Define the CentOS 7 AMI by:
# CentOS, Latest, x86_64, EBS, HVM, product_code
# See: https://wiki.centos.org/Cloud/AWS
data "aws_ami" "CentOS7" {
  most_recent = true

  owners = ["679593333241"] // AWS Marketplace ID

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "product-code"
    values = ["aw0evgkw8e5c1q413zgy5pjce"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

}
