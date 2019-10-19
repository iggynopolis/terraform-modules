
# Outputs for TF Regression Testbed CSR vpc setup

output "vpc_id" {
  value   = aws_vpc.vpc[*].id
}

output "vpc_name" {
  value   = aws_vpc.vpc[*].tags.Name
}

output "subnet_name" {
  value   = concat(
    aws_subnet.public_subnet1[*].tags.Name,
    aws_subnet.public_subnet2[*].tags.Name,
    aws_subnet.private_subnet[*].tags.Name
  )
}

output "subnet_cidr" {
  value   = concat(
    aws_subnet.public_subnet1[*].cidr_block,
    aws_subnet.public_subnet2[*].cidr_block,
    aws_subnet.private_subnet[*].cidr_block
  )
}

output "csr_name" {
	value		= concat(
    aws_instance.csr_instance1[*].tags.Name,
    aws_instance.csr_instance2[*].tags.Name
  )
}

output "csr_public_ip" {
  value   = concat(
    aws_eip.eip1[*].public_ip,
    aws_eip.eip2[*].public_ip
  )
}

output "csr_private_ip" {
  value   = concat(
    aws_instance.csr_instance1[*].private_ip,
    aws_instance.csr_instance2[*].private_ip
  )
}

output "csr_id" {
	value		= concat(
    aws_instance.csr_instance1[*].id,
    aws_instance.csr_instance2[*].id
  )
}
