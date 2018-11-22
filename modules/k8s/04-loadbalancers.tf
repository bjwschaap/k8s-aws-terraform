// This file contains all ELB configurations for our k8s cluster

// Internal loadbalancer for Master nodes
resource "aws_elb" "master_int_elb" {
  name                      = "k8s-int-master-elb"
  idle_timeout              = 300
  cross_zone_load_balancing = true
  internal                  = true
  security_groups           = ["${aws_security_group.master_int_elb_sg.id}"]
  subnets                   = ["${aws_subnet.private-subnets.*.id}"]
  instances                 = ["${aws_instance.master_nodes.*.id}"]

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 2
    target              = "${var.master_health_target}"
    interval            = 5
  }

  listener {
    instance_port     = "${var.master_api_port}"
    instance_protocol = "TCP"
    lb_port           = "${var.master_api_port}"
    lb_protocol       = "TCP"
  }

  tags {
    Name    = "k8s-int-master-elb"
    Project = "k8s"
  }
}

// External loadbalancer for Master nodes
resource "aws_elb" "master_ext_elb" {
  name                      = "k8s-ext-master-elb"
  idle_timeout              = 300
  cross_zone_load_balancing = true
  internal                  = false
  security_groups           = ["${aws_security_group.master_ext_elb_sg.id}"]
  subnets                   = ["${aws_subnet.public-subnets.*.id}"]
  instances                 = ["${aws_instance.master_nodes.*.id}"]

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 2
    target              = "${var.master_health_target}"
    interval            = 5
  }

  listener {
    instance_port     = "${var.master_api_port}"
    instance_protocol = "TCP"
    lb_port           = "${var.master_api_port}"
    lb_protocol       = "TCP"
  }

  tags {
    Name    = "k8s-ext-master-elb"
    Project = "k8s"
  }
}

// Loadbalancer for Infra nodes
resource "aws_elb" "infra_elb" {
  name                      = "k8s-infra-elb"
  idle_timeout              = 300
  cross_zone_load_balancing = true
  internal                  = true
  security_groups           = ["${aws_security_group.infra_elb_sg.id}"]
  subnets                   = ["${aws_subnet.public-subnets.*.id}"]
  instances                 = ["${aws_instance.infra_nodes.*.id}"]

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 2
    target              = "TCP:443"
    interval            = 5
  }

  listener {
    instance_port     = 443
    instance_protocol = "TCP"
    lb_port           = 443
    lb_protocol       = "TCP"
  }

  listener {
    instance_port     = 80
    instance_protocol = "TCP"
    lb_port           = 80
    lb_protocol       = "TCP"
  }

  tags {
    Name    = "k8s-infra-elb"
    Project = "k8s"
  }
}
