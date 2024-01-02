########################################################################
# Provides Information About Firewall Resources Created by this Module #
########################################################################

output "arn" {
  description = "Amazon Resource Name (ARN) of the VPC Security Group"
  value       = aws_security_group.vpc_endpoint.arn
}

output "egress_rules" {
  description = "List of Egress Rule IDs Associated w/ this Firewall (by this Module)"

  value = flatten(concat(
    aws_vpc_security_group_egress_rule.vpc_endpoint_all_ipv4.*.id,
    aws_vpc_security_group_egress_rule.vpc_endpoint_all_ipv6.*.id,
  ))
}

output "id" {
  description = "Unique ID Assigned to the VPC Security Group"
  value       = aws_security_group.vpc_endpoint.id
}

output "ingress_rules" {
  description = "List of Ingress Rule IDs Associated w/ this Firewall (by this Module)"

  value = flatten(concat(
    aws_vpc_security_group_ingress_rule.vpc_endpoint_tcp_https_ipv4.*.id,
    aws_vpc_security_group_ingress_rule.vpc_endpoint_tcp_https_ipv6.*.id,
    aws_vpc_security_group_ingress_rule.vpc_endpoint_tcp_https_sg.*.id,
  ))
}

output "network_id" {
  description = "VPC ID of the VPC Associated w/ this VPC Security Group"
  value       = aws_security_group.vpc_endpoint.vpc_id
}
