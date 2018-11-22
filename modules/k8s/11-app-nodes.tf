// This file contains the definition of the k8s application/worker nodes
data "template_file" "app_node_user_data" {
  count = "${var.app_node_count}"
  template = "${file("${path.module}/files/node_user_data.yml")}"

  vars {
    hostname = "k8s-app-${count.index + 1}"
    domain   = "${var.public_hosted_zone}"
  }
}

resource "aws_instance" "app_nodes" {
  count                   = "${var.app_node_count}"
  ami                     = "${data.aws_ami.CentOS7.id}"
  instance_type           = "${var.app_instance_type}"
  iam_instance_profile    = "${aws_iam_instance_profile.node_instance_profile.id}"
  subnet_id               = "${element(aws_subnet.private-subnets.*.id, count.index)}"
  key_name                = "${aws_key_pair.keypair.key_name}"
  user_data               = "${element(data.template_file.app_node_user_data.*.rendered, count.index)}"
  source_dest_check       = false
  vpc_security_group_ids  = [
    "${aws_security_group.node_sg.id}"
  ]
  root_block_device       = {
    volume_type           = "gp2"
    delete_on_termination = true
  }
  ebs_block_device        = {
    device_name           = "/dev/sda1"
    delete_on_termination = true
    volume_size           = "50"
    volume_type           = "gp2"
  }
  // Disk for Docker images and volumes
  ebs_block_device        = {
    device_name           = "/dev/xvdb"
    delete_on_termination = true
    volume_size           = "25"
    volume_type           = "gp2"
  }
  depends_on              = [
    "aws_iam_instance_profile.node_instance_profile",
    "aws_subnet.private-subnets"
  ]

  # Needed because of https://github.com/terraform-providers/terraform-provider-aws/issues/36
  lifecycle {
    ignore_changes = [ "ebs_block_device" ]
  }

  tags {
    Name                                     = "k8s-app-${count.index + 1}.${var.public_hosted_zone}"
    Project                                  = "k8s"
    k8s-role                                 = "app"
    kubespray-role                           = "kube-node"
    KubernetesCluster                        = "${var.stackname}"
    "kubernetes.io/cluster/${var.stackname}" = "${var.stackname}-${var.region}"
  }
}
