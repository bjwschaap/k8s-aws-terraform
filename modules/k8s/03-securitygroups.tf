// This file contains all securitygroups for incoming/outgoing network traffic.

// Bastion host rules
resource "aws_security_group" "bastion_sg" {
  name        = "k8s-bastion-sg"
  description = "Network traffic rules for the Bastion host"
  vpc_id      = "${aws_vpc.k8s.id}"

  ingress {
    description = "Allow SSH from internet to Bastion host"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow ICMP from within the VPC to Bastion host"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  egress {
    description = "Allow everything to outside"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name    = "k8s-bastion-sg"
    Project = "k8s"
  }
}

// ETCD rules
resource "aws_security_group" "etcd_sg" {
  name        = "k8s-etcd-sg"
  description = "Network traffic rules for the ETCD hosts"
  vpc_id      = "${aws_vpc.k8s.id}"

  tags {
    Name    = "k8s-etcd-sg"
    Project = "k8s"
  }
}

resource "aws_security_group_rule" "etcd_etcd_ingress" {
  security_group_id        = "${aws_security_group.etcd_sg.id}"
  type                     = "ingress"
  from_port                = "2379"
  to_port                  = "2379"
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.etcd_sg.id}"
}

resource "aws_security_group_rule" "etcd_master_ingress" {
  security_group_id        = "${aws_security_group.etcd_sg.id}"
  type                     = "ingress"
  from_port                = "2379"
  to_port                  = "2380"
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.master_sg.id}"
}

resource "aws_security_group_rule" "etcd_peer_ingress" {
  security_group_id        = "${aws_security_group.etcd_sg.id}"
  type                     = "ingress"
  from_port                = "2379"
  to_port                  = "2380"
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.etcd_sg.id}"
}

resource "aws_security_group_rule" "etcd_worker_ingress" {
  security_group_id        = "${aws_security_group.etcd_sg.id}"
  type                     = "ingress"
  from_port                = "2379"
  to_port                  = "2380"
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.node_sg.id}"
}

resource "aws_security_group_rule" "etcd_infra_ingress" {
  security_group_id        = "${aws_security_group.etcd_sg.id}"
  type                     = "ingress"
  from_port                = "2379"
  to_port                  = "2380"
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.infra_sg.id}"
}

resource "aws_security_group_rule" "etcd_egress" {
  security_group_id        = "${aws_security_group.etcd_sg.id}"
  type                     = "egress"
  from_port                = "0"
  to_port                  = "0"
  protocol                 = "-1"
  cidr_blocks              = ["0.0.0.0/0"]
}

// Infra nodes loadbalancer rules
resource "aws_security_group" "infra_elb_sg" {
  name        = "k8s-router-sg"
  description = "Network traffic rules for the infra nodes ELB"
  vpc_id      = "${aws_vpc.k8s.id}"

  ingress {
    description = "Allow HTTP from internet to infra nodes"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS from internet to infra nodes"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow everything to outside"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name    = "k8s-router-sg"
    Project = "k8s"
  }
}

resource "aws_security_group_rule" "infra_elb_egress_http" {
  security_group_id        = "${aws_security_group.infra_elb_sg.id}"
  type                     = "egress"
  from_port                = "80"
  to_port                  = "80"
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.infra_sg.id}"
}

resource "aws_security_group_rule" "infra_elb_egress_elastic_api" {
  security_group_id        = "${aws_security_group.infra_elb_sg.id}"
  type                     = "egress"
  from_port                = "9200"
  to_port                  = "9200"
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.infra_sg.id}"
}

resource "aws_security_group_rule" "infra_elb_egress_elastic_cluster" {
  security_group_id        = "${aws_security_group.infra_elb_sg.id}"
  type                     = "egress"
  from_port                = "9300"
  to_port                  = "9300"
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.infra_sg.id}"
}

resource "aws_security_group_rule" "infra_elb_egress_logging" {
  security_group_id        = "${aws_security_group.infra_elb_sg.id}"
  type                     = "egress"
  from_port                = "443"
  to_port                  = "443"
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.infra_sg.id}"
}

// Master external loadbalancer rules
resource "aws_security_group" "master_ext_elb_sg" {
  name        = "k8s-elb-master-sg"
  description = "Master external Loadbalancer"
  vpc_id      = "${aws_vpc.k8s.id}"

  ingress {
    description = "Allow external access to the k8s Web Console"
    from_port   = "${var.master_api_port}"
    to_port     = "${var.master_api_port}"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name    = "k8s-elb-master-sg"
    Project = "k8s"
  }
}

resource "aws_security_group_rule" "master_ext_elb_api_egress" {
  security_group_id        = "${aws_security_group.master_ext_elb_sg.id}"
  type                     = "egress"
  from_port                = "${var.master_api_port}"
  to_port                  = "${var.master_api_port}"
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.master_sg.id}"
}

// Master internal loadbalancer rules
resource "aws_security_group" "master_int_elb_sg" {
  name        = "k8s-int-elb-master-sg"
  description = "Master internal Loadbalancer"
  vpc_id      = "${aws_vpc.k8s.id}"

  tags {
    Name    = "k8s-int-elb-master-sg"
    Project = "k8s"
  }
}

resource "aws_security_group_rule" "master_int_elb_api_egress" {
  security_group_id        = "${aws_security_group.master_int_elb_sg.id}"
  type                     = "egress"
  from_port                = "${var.master_api_port}"
  to_port                  = "${var.master_api_port}"
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.master_sg.id}"
}

resource "aws_security_group_rule" "master_int_elb_api_ingress" {
  security_group_id        = "${aws_security_group.master_int_elb_sg.id}"
  type                     = "ingress"
  from_port                = "${var.master_api_port}"
  to_port                  = "${var.master_api_port}"
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.master_sg.id}"
}

resource "aws_security_group_rule" "master_int_elb_api_ingress_nodes" {
  security_group_id        = "${aws_security_group.master_int_elb_sg.id}"
  type                     = "ingress"
  from_port                = "${var.master_api_port}"
  to_port                  = "${var.master_api_port}"
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.node_sg.id}"
}

// Infra nodes rules
resource "aws_security_group" "infra_sg" {
  name        = "k8s-infra-node-sg"
  description = "Infra nodes security group"
  vpc_id      = "${aws_vpc.k8s.id}"

  egress {
    description = "Allow everything to outside"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name    = "k8s-infra-node-sg"
    Project = "k8s"
  }
}

resource "aws_security_group_rule" "infra_elb_http_ingress" {
  security_group_id        = "${aws_security_group.infra_sg.id}"
  type                     = "ingress"
  from_port                = "80"
  to_port                  = "80"
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.infra_elb_sg.id}"
}

resource "aws_security_group_rule" "infra_elb_https_ingress" {
  security_group_id        = "${aws_security_group.infra_sg.id}"
  type                     = "ingress"
  from_port                = "443"
  to_port                  = "443"
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.infra_elb_sg.id}"
}

// Application/Worker nodes rules
resource "aws_security_group" "node_sg" {
  name        = "k8s-node-sg"
  description = "Application/Worker nodes security group"
  vpc_id      = "${aws_vpc.k8s.id}"

  egress {
    description = "Allow everything to outside"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name    = "k8s-node-sg"
    Project = "k8s"
  }
}

// Worker node kubelet healtheck port must be accessible from master nodes
resource "aws_security_group_rule" "node_kubelet_master_ingress" {
  security_group_id        = "${aws_security_group.node_sg.id}"
  type                     = "ingress"
  from_port                = "10250"
  to_port                  = "10250"
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.master_sg.id}"
}

// Intra worker node kubelet access
resource "aws_security_group_rule" "node_kubelet_node_ingress" {
  security_group_id        = "${aws_security_group.node_sg.id}"
  type                     = "ingress"
  from_port                = "10250"
  to_port                  = "10250"
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.node_sg.id}"
}

// Calico BGP between workers (in case it's used..)
resource "aws_security_group_rule" "node_bgp_node_ingress" {
  security_group_id        = "${aws_security_group.node_sg.id}"
  type                     = "ingress"
  from_port                = "179"
  to_port                  = "179"
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.node_sg.id}"
}

resource "aws_security_group_rule" "node_vxlan_node_ingress" {
  security_group_id        = "${aws_security_group.node_sg.id}"
  type                     = "ingress"
  from_port                = "4789"
  to_port                  = "4789"
  protocol                 = "udp"
  source_security_group_id = "${aws_security_group.node_sg.id}"
}

// Allow access into Calico Typha agents
resource "aws_security_group_rule" "node_typha_node_ingress" {
  security_group_id        = "${aws_security_group.node_sg.id}"
  type                     = "ingress"
  from_port                = "5473"
  to_port                  = "5473"
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.node_sg.id}"
}

// Allow IP-in-IP between hosts
resource "aws_security_group_rule" "node_ip_in_ip_node_ingress" {
  security_group_id        = "${aws_security_group.node_sg.id}"
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "4"
  source_security_group_id = "${aws_security_group.node_sg.id}"
}

resource "aws_security_group_rule" "node_ssh_bastion_ingress" {
  security_group_id        = "${aws_security_group.node_sg.id}"
  type                     = "ingress"
  from_port                = "22"
  to_port                  = "22"
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.bastion_sg.id}"
}

resource "aws_security_group_rule" "node_icmp_ingress" {
  security_group_id        = "${aws_security_group.node_sg.id}"
  type                     = "ingress"
  from_port                = "-1"
  to_port                  = "-1"
  protocol                 = "icmp"
  cidr_blocks              = ["${var.vpc_cidr}"]
}

// Master nodes rules
resource "aws_security_group" "master_sg" {
  name        = "k8s-master-sg"
  description = "Master nodes security group"
  vpc_id      = "${aws_vpc.k8s.id}"

  egress {
    description = "Allow everything to outside"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name    = "k8s-master-sg"
    Project = "k8s"
  }
}

resource "aws_security_group_rule" "master_int_elb_ingress" {
  security_group_id        = "${aws_security_group.master_sg.id}"
  type                     = "ingress"
  from_port                = "${var.master_api_port}"
  to_port                  = "${var.master_api_port}"
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.master_int_elb_sg.id}"
}

resource "aws_security_group_rule" "master_ext_elb_ingress" {
  security_group_id        = "${aws_security_group.master_sg.id}"
  type                     = "ingress"
  from_port                = "${var.master_api_port}"
  to_port                  = "${var.master_api_port}"
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.master_ext_elb_sg.id}"
}

resource "aws_security_group_rule" "api_int_elb_ingress" {
  security_group_id        = "${aws_security_group.master_sg.id}"
  type                     = "ingress"
  from_port                = 8443
  to_port                  = 8444
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.master_int_elb_sg.id}"
}

resource "aws_security_group_rule" "api_ext_elb_ingress" {
  security_group_id        = "${aws_security_group.master_sg.id}"
  type                     = "ingress"
  from_port                = 8443
  to_port                  = 8444
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.master_ext_elb_sg.id}"
}

resource "aws_security_group_rule" "master_node_dns_udp_ingress" {
  security_group_id        = "${aws_security_group.master_sg.id}"
  type                     = "ingress"
  from_port                = "8053"
  to_port                  = "8053"
  protocol                 = "udp"
  source_security_group_id = "${aws_security_group.node_sg.id}"
}

resource "aws_security_group_rule" "master_node_dns_tcp_ingress" {
  security_group_id        = "${aws_security_group.master_sg.id}"
  type                     = "ingress"
  from_port                = "8053"
  to_port                  = "8053"
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.node_sg.id}"
}

resource "aws_security_group_rule" "master_node_api_ingress" {
  security_group_id        = "${aws_security_group.master_sg.id}"
  type                     = "ingress"
  from_port                = "${var.master_api_port}"
  to_port                  = "${var.master_api_port}"
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.node_sg.id}"
}

resource "aws_security_group_rule" "master_api_node_api_ingress" {
  security_group_id        = "${aws_security_group.master_sg.id}"
  type                     = "ingress"
  from_port                = 8443
  to_port                  = 8444
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.node_sg.id}"
}

resource "aws_security_group_rule" "master_node_logging_tcp_ingress" {
  security_group_id        = "${aws_security_group.master_sg.id}"
  type                     = "ingress"
  from_port                = "24224"
  to_port                  = "24224"
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.node_sg.id}"
}

resource "aws_security_group_rule" "master_node_logging_udp_ingress" {
  security_group_id        = "${aws_security_group.master_sg.id}"
  type                     = "ingress"
  from_port                = "24224"
  to_port                  = "24224"
  protocol                 = "udp"
  source_security_group_id = "${aws_security_group.node_sg.id}"
}

resource "aws_security_group_rule" "master_master_api_ingress" {
  security_group_id        = "${aws_security_group.master_sg.id}"
  type                     = "ingress"
  from_port                = "${var.master_api_port}"
  to_port                  = "${var.master_api_port}"
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.master_sg.id}"
}

resource "aws_security_group_rule" "master_api_master_api_ingress" {
  security_group_id        = "${aws_security_group.master_sg.id}"
  type                     = "ingress"
  from_port                = 8443
  to_port                  = 8444
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.master_sg.id}"
}
