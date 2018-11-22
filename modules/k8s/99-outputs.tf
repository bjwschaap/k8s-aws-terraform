output "bastion-public_dns" {
  value = "${aws_route53_record.bastion_node.name}"
}
output "bastion-public_ip" {
  value = "${aws_eip.bastion.public_ip}"
}
output "bastion-private_dns" {
  value = "${aws_instance.bastion_node.private_dns}"
}
output "bastion-private_ip" {
  value = "${aws_instance.bastion_node.private_ip}"
}
output "master-public_dns" {
  value = "${aws_route53_record.k8s-master.name}"
}
