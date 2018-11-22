// This file contains all IAM policies and roles for our k8s Resources

// Master Policy
resource "aws_iam_role" "master_policy" {
  name               = "k8s-master-policy"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

// Master Policy
resource "aws_iam_role" "node_policy" {
  name               = "k8s-node-policy"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

// Policy for application/worker nodes
resource "aws_iam_role_policy" "node_policy" {
  name       = "node-describe"
  role       = "${aws_iam_role.node_policy.id}"
  depends_on = ["aws_iam_role.node_policy"]
  policy     = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:Describe*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

// Policy for master nodes
resource "aws_iam_role_policy" "master_policy" {
  name       = "master-ec2-all"
  role       = "${aws_iam_role.master_policy.id}"
  depends_on = ["aws_iam_role.master_policy"]
  policy     = <<EOF
{
  "Version" : "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
         "ec2:DescribeVolume*",
         "ec2:CreateVolume",
         "ec2:CreateTags",
         "ec2:DescribeInstance*",
         "ec2:AttachVolume",
         "ec2:DetachVolume",
         "ec2:DeleteVolume",
         "ec2:DescribeSubnets",
         "ec2:CreateSecurityGroup",
         "ec2:DescribeSecurityGroups",
         "elasticloadbalancing:DescribeTags",
         "elasticloadbalancing:CreateLoadBalancerListeners",
         "ec2:DescribeRouteTables",
         "elasticloadbalancing:ConfigureHealthCheck",
         "ec2:AuthorizeSecurityGroupIngress",
         "elasticloadbalancing:DeleteLoadBalancerListeners",
         "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
         "elasticloadbalancing:DescribeLoadBalancers",
         "elasticloadbalancing:CreateLoadBalancer",
         "elasticloadbalancing:DeleteLoadBalancer",
         "elasticloadbalancing:ModifyLoadBalancerAttributes",
         "elasticloadbalancing:DescribeLoadBalancerAttributes"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

// Master Instance Profile
resource "aws_iam_instance_profile" "master_instance_profile" {
  name       = "master-instance-profile"
  role       = "${aws_iam_role.master_policy.name}"
  depends_on = ["aws_iam_role_policy.master_policy"]
}

// Node Instance Profile
resource "aws_iam_instance_profile" "node_instance_profile" {
  name       = "node-instance-profile"
  role       = "${aws_iam_role.node_policy.name}"
  depends_on = ["aws_iam_role_policy.node_policy"]
}

//  Create a user and access key for k8s-only permissions
resource "aws_iam_user" "k8s-aws-user" {
  name = "k8s-aws-user"
  path = "/"
}

resource "aws_iam_user_policy" "k8s-aws-user" {
  name = "k8s-aws-user-policy"
  user = "${aws_iam_user.k8s-aws-user.name}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeVolume*",
        "ec2:CreateVolume",
        "ec2:CreateTags",
        "ec2:DescribeInstance*",
        "ec2:AttachVolume",
        "ec2:DetachVolume",
        "ec2:DeleteVolume",
        "ec2:DescribeSubnets",
        "ec2:CreateSecurityGroup",
        "ec2:DescribeSecurityGroups",
        "elasticloadbalancing:DescribeTags",
        "elasticloadbalancing:CreateLoadBalancerListeners",
        "ec2:DescribeRouteTables",
        "elasticloadbalancing:ConfigureHealthCheck",
        "ec2:AuthorizeSecurityGroupIngress",
        "elasticloadbalancing:DeleteLoadBalancerListeners",
        "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
        "elasticloadbalancing:DescribeLoadBalancers",
        "elasticloadbalancing:CreateLoadBalancer",
        "elasticloadbalancing:DeleteLoadBalancer",
        "elasticloadbalancing:ModifyLoadBalancerAttributes",
        "elasticloadbalancing:DescribeLoadBalancerAttributes"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_access_key" "k8s-aws-user" {
  user    = "${aws_iam_user.k8s-aws-user.name}"
}
