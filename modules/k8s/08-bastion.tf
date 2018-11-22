// this file describes the bastion host for SSH access into our k8s cluster

// First create the keypair to get onto the hosts
resource "aws_key_pair" "keypair" {
  key_name   = "${var.key_name}"
  public_key = "${file(var.public_key_path)}"
}

//  Launch configuration for the consul cluster auto-scaling group.
resource "aws_instance" "bastion_node" {
  ami                     = "${data.aws_ami.CentOS7.id}"
  instance_type           = "t2.micro"
  iam_instance_profile    = "${aws_iam_instance_profile.node_instance_profile.id}"
  subnet_id               = "${aws_subnet.public-subnets.0.id}"
  key_name                = "${aws_key_pair.keypair.key_name}"
  user_data               = "${file("${path.module}/files/bastion_user_data.yml")}"
  vpc_security_group_ids  = [
    "${aws_security_group.bastion_sg.id}"
  ]
  depends_on              = [
    "aws_iam_instance_profile.node_instance_profile",
    "aws_subnet.public-subnets"
  ]
  root_block_device       = {
    volume_type           = "gp2"
    delete_on_termination = true
  }

  tags {
    Name    = "bastion.${data.aws_route53_zone.selected.name}"
    Project = "k8s"
  }
}

// Elastic IP address for the bastion node
resource "aws_eip" "bastion" {
  vpc    = true

  tags {
    Name    = "${var.vpc_name}-bastion-eip"
    Project = "k8s"
  }
}

// Assign the EIP to the node
resource "aws_eip_association" "bastion_eip_assoc" {
  instance_id   = "${aws_instance.bastion_node.id}"
  allocation_id = "${aws_eip.bastion.id}"
}
