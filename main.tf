#######################################
# Locally-Available Dynamic Variables #
#######################################

locals {
  sg_prefix = coalesce(var.firewall_prefix, try("${data.aws_vpc.selected.tags["Name"]}-", ""))
}

#########################################################
# Retrieves Information About the Targeted VPC Instance #
#########################################################

data "aws_vpc" "selected" {
  id = var.network_id
}

##########################################################
# Creates AWS Virtual Private Cloud (VPC) Security Group #
##########################################################

resource "aws_security_group" "vpc_endpoint" {
  description = "Manages All Firewall Rules for VPC Interface Endpoints"
  name        = "${local.sg_prefix}${var.firewall_name}"
  vpc_id      = var.network_id

  tags = merge({
    Name = "${local.sg_prefix}${var.firewall_name}"
  }, var.resource_tags)
}

###################################################################
# Creates Default VPC Security Group Rule for IPv4 Egress Traffic #
###################################################################

resource "aws_vpc_security_group_egress_rule" "vpc_endpoint_all_ipv4" {
  cidr_ipv4         = var.firewall_allowed_ipv4_egress_cidrs[count.index]
  count             = length(var.firewall_allowed_ipv4_egress_cidrs)
  description       = "Allows Egress via All Ports and Protocols Based on Destination CIDR"
  ip_protocol       = "-1"
  security_group_id = aws_security_group.vpc_endpoint.id

  tags = {
    CIDR = var.firewall_allowed_ipv4_egress_cidrs[count.index]
    Name = "${aws_security_group.vpc_endpoint.name}-all-all-ipv4"
  }
}

###################################################################
# Creates Default VPC Security Group Rule for IPv6 Egress Traffic #
###################################################################

resource "aws_vpc_security_group_egress_rule" "vpc_endpoint_all_ipv6" {
  cidr_ipv6         = var.firewall_allowed_ipv6_egress_cidrs[count.index]
  count             = length(var.firewall_allowed_ipv6_egress_cidrs)
  description       = "Allows Egress via All Ports and Protocols Based on Destination CIDR"
  ip_protocol       = "-1"
  security_group_id = aws_security_group.vpc_endpoint.id

  tags = {
    CIDR = var.firewall_allowed_ipv6_egress_cidrs[count.index]
    Name = "${aws_security_group.vpc_endpoint.name}-all-all-ipv6"
  }
}

############################################################################
# Creates VPC Security Group Rule(s) Permitting HTTPS Access via IPv4 CIDR #
############################################################################

resource "aws_vpc_security_group_ingress_rule" "vpc_endpoint_tcp_https_ipv4" {
  cidr_ipv4         = var.firewall_allowed_ipv4_ingress_cidrs[count.index]
  count             = length(var.firewall_allowed_ipv4_ingress_cidrs)
  description       = "Allows HTTPS Traffic via TCP Protocol from Specific CIDR(s)"
  from_port         = var.network_default_https_port
  ip_protocol       = "tcp"
  security_group_id = aws_security_group.vpc_endpoint.id
  to_port           = var.network_default_https_port
}

############################################################################
# Creates VPC Security Group Rule(s) Permitting HTTPS Access via IPv6 CIDR #
############################################################################

resource "aws_vpc_security_group_ingress_rule" "vpc_endpoint_tcp_https_ipv6" {
  cidr_ipv6         = var.firewall_allowed_ipv6_ingress_cidrs[count.index]
  count             = length(var.firewall_allowed_ipv6_ingress_cidrs)
  description       = "Allows HTTPS Traffic via TCP Protocol from Specific CIDR(s)"
  from_port         = var.network_default_https_port
  ip_protocol       = "tcp"
  security_group_id = aws_security_group.vpc_endpoint.id
  to_port           = var.network_default_https_port
}

#####################################################################################
# Creates VPC Security Group Rule(s) Permitting HTTPS Access via VPC Security Group #
#####################################################################################

resource "aws_vpc_security_group_ingress_rule" "vpc_endpoint_tcp_https_sg" {
  count                        = length(var.firewall_allowed_sg_ingress_https)
  description                  = "Allows HTTPS Traffic via TCP Protocol from Specific CIDR(s)"
  from_port                    = var.network_default_https_port
  ip_protocol                  = "tcp"
  referenced_security_group_id = var.firewall_allowed_sg_ingress_https[count.index]
  security_group_id            = aws_security_group.vpc_endpoint.id
  to_port                      = var.network_default_https_port
}
