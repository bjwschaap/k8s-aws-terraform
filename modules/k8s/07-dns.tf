// This file contains all DNS (Route53) resources

data "aws_route53_zone" "selected" {
  name         = "${var.public_hosted_zone}."
}

resource "aws_route53_zone" "k8s_reverse" {
  name          = "${format("%s.%s.in-addr.arpa", element(split(".", var.vpc_cidr), 1), element(split(".", var.vpc_cidr), 0))}"
  comment       = "k8s Reverse Private DNS Zone"
  vpc_id        = "${aws_vpc.k8s.id}"
}

// Record pointing to the external ELB for the k8s Masters
resource "aws_route53_record" "k8s-master" {
  zone_id = "${data.aws_route53_zone.selected.zone_id}"
  name    = "k8s-master.${data.aws_route53_zone.selected.name}"
  type    = "A"

  alias {
    name                   = "${aws_elb.master_ext_elb.dns_name}"
    zone_id                = "${aws_elb.master_ext_elb.zone_id}"
    evaluate_target_health = true
  }
}

// Record pointing to the internal ELB for the k8s Masters
resource "aws_route53_record" "internal-k8s-master" {
  zone_id = "${data.aws_route53_zone.selected.zone_id}"
  name    = "internal-k8s-master.${data.aws_route53_zone.selected.name}"
  type    = "A"

  alias {
    name                   = "${aws_elb.master_int_elb.dns_name}"
    zone_id                = "${aws_elb.master_int_elb.zone_id}"
    evaluate_target_health = true
  }
}

// Record  for the application wildcard domain, pointing to the ELB for the k8s Infra nodes
resource "aws_route53_record" "app_wildcard" {
  zone_id = "${data.aws_route53_zone.selected.zone_id}"
  name    = "*.${var.app_dns_prefix}.${data.aws_route53_zone.selected.name}"
  type    = "A"

  alias {
    name                   = "${aws_elb.infra_elb.dns_name}"
    zone_id                = "${aws_elb.infra_elb.zone_id}"
    evaluate_target_health = true
  }
}

// Records for master nodes
resource "aws_route53_record" "master_nodes" {
  count   = "${var.master_node_count}"
  zone_id = "${data.aws_route53_zone.selected.zone_id}"
  name    = "k8s-master-${count.index + 1}.${data.aws_route53_zone.selected.name}"
  type    = "A"
  ttl     = 300
  records = ["${element(aws_instance.master_nodes.*.private_ip, count.index)}"]
}

resource "aws_route53_record" "master_nodes_reverse" {
  count   = "${var.master_node_count}"
  zone_id = "${aws_route53_zone.k8s_reverse.zone_id}"
  name = "${format(
    "%s.%s.%s.%s.in-addr.arpa.",
      element( split(".", element(aws_instance.master_nodes.*.private_ip, count.index)) ,3),
      element( split(".", element(aws_instance.master_nodes.*.private_ip, count.index)) ,2),
      element( split(".", element(aws_instance.master_nodes.*.private_ip, count.index)) ,1),
      element( split(".", element(aws_instance.master_nodes.*.private_ip, count.index)) ,0),
    )
  }"
  type    = "PTR"
  ttl     = 300
  records = ["${element(aws_instance.master_nodes.*.tags.Name, count.index)}"]
}

// Records for Infra nodes
resource "aws_route53_record" "infra_nodes" {
  count   = "${var.infra_node_count}"
  zone_id = "${data.aws_route53_zone.selected.zone_id}"
  name    = "k8s-infra-${count.index + 1}.${data.aws_route53_zone.selected.name}"
  type    = "A"
  ttl     = 300
  records = ["${element(aws_instance.infra_nodes.*.private_ip, count.index)}"]
}

resource "aws_route53_record" "infra_nodes_reverse" {
  count   = "${var.infra_node_count}"
  zone_id = "${aws_route53_zone.k8s_reverse.zone_id}"
  name = "${format(
    "%s.%s.%s.%s.in-addr.arpa.",
      element( split(".", element(aws_instance.infra_nodes.*.private_ip, count.index)) ,3),
      element( split(".", element(aws_instance.infra_nodes.*.private_ip, count.index)) ,2),
      element( split(".", element(aws_instance.infra_nodes.*.private_ip, count.index)) ,1),
      element( split(".", element(aws_instance.infra_nodes.*.private_ip, count.index)) ,0),
    )
  }"
  type    = "PTR"
  ttl     = 300
  records = ["${element(aws_instance.infra_nodes.*.tags.Name, count.index)}"]
}

// Records for the app/worker nodes
resource "aws_route53_record" "app_nodes" {
  count   = "${var.app_node_count}"
  zone_id = "${data.aws_route53_zone.selected.zone_id}"
  name    = "k8s-app-${count.index + 1}.${data.aws_route53_zone.selected.name}"
  type    = "A"
  ttl     = 300
  records = ["${element(aws_instance.app_nodes.*.private_ip, count.index)}"]
}

resource "aws_route53_record" "app_nodes_reverse" {
  count   = "${var.app_node_count}"
  zone_id = "${aws_route53_zone.k8s_reverse.zone_id}"
  name = "${format(
    "%s.%s.%s.%s.in-addr.arpa.",
      element( split(".", element(aws_instance.app_nodes.*.private_ip, count.index)) ,3),
      element( split(".", element(aws_instance.app_nodes.*.private_ip, count.index)) ,2),
      element( split(".", element(aws_instance.app_nodes.*.private_ip, count.index)) ,1),
      element( split(".", element(aws_instance.app_nodes.*.private_ip, count.index)) ,0),
    )
  }"
  type    = "PTR"
  ttl     = 300
  records = ["${element(aws_instance.app_nodes.*.tags.Name, count.index)}"]
}

// Record for the Bastion host
resource "aws_route53_record" "bastion_node" {
  zone_id = "${data.aws_route53_zone.selected.zone_id}"
  name    = "bastion.${data.aws_route53_zone.selected.name}"
  type    = "A"
  ttl     = 300
  records = ["${aws_eip.bastion.public_ip}"]
}
