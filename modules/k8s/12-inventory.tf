//  Generates the inventory file needed by Ansible to perform the k8s
// installation.
data "template_file" "master_entries" {
  count = "${var.master_node_count}"
  template = "$${hostname} k8s_node_labels=\"{'role': 'master'}\" k8s_hostname=$${private_dns}"
  vars {
    hostname    = "${element(aws_instance.master_nodes.*.tags.Name, count.index)}"
    private_dns = "${element(aws_instance.master_nodes.*.private_dns, count.index)}"
  }
}

data "template_file" "infra_entries" {
  count = "${var.infra_node_count}"
  template = "$${hostname} k8s_node_labels=\"{'role': 'infra', 'region': 'infra'}\" k8s_hostname=$${private_dns}"
  vars {
    hostname    = "${element(aws_instance.infra_nodes.*.tags.Name, count.index)}"
    private_dns = "${element(aws_instance.infra_nodes.*.private_dns, count.index)}"
  }
}

data "template_file" "app_entries" {
  count = "${var.app_node_count}"
  template = "$${hostname} k8s_node_labels=\"{'role': 'app'}\" k8s_hostname=$${private_dns}"
  vars {
    hostname    = "${element(aws_instance.app_nodes.*.tags.Name, count.index)}"
    private_dns = "${element(aws_instance.app_nodes.*.private_dns, count.index)}"
  }
}

data "template_file" "inventory" {
  template = "${file("${path.module}/files/inventory.template.cfg")}"

  vars {
    access_key           = "${aws_iam_access_key.k8s-aws-user.id}"
    secret_key           = "${aws_iam_access_key.k8s-aws-user.secret}"
    public_hostname      = "${aws_route53_record.k8s-master.name}"
    internal_hostname    = "${aws_route53_record.internal-k8s-master.name}"
    hosted_zone          = "${var.public_hosted_zone}"
    app_node_count       = "${var.app_node_count}"
    master_node_count    = "${var.master_node_count}"
    infra_node_count     = "${var.infra_node_count}"
    app_dns_prefix       = "${var.app_dns_prefix}"
    vpc_cidr             = "${var.vpc_cidr}"
    cluster_network_cidr = "${var.osm_cluster_network_cidr}"
    stackname            = "${var.stackname}"
    github_client_id     = "${var.github_client_id}"
    github_client_secret = "${var.github_client_secret}"
    github_organization  = "${var.github_organization}"
    registry_s3_bucket   = "${var.registry_s3_bucket_name}"
    master_entries       = "${join("\n", data.template_file.master_entries.*.rendered)}"
    infra_entries        = "${join("\n", data.template_file.infra_entries.*.rendered)}"
    app_entries          = "${join("\n", data.template_file.app_entries.*.rendered)}"
  }
}

//  Create the inventory.
resource "local_file" "inventory" {
  content     = "${data.template_file.inventory.rendered}"
  filename = "${path.cwd}/inventory.cfg"
}
