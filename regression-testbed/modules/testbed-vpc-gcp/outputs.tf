# Outputs for TF Regression Testbed GCP VPC environment setup

output "vpc_id" {
  value   = google_compute_network.vpc[*].self_link
}

output "vpc_name" {
  value   = google_compute_network.vpc[*].name
}

output "subnet_name" {
  value   = concat(
    google_compute_subnetwork.public_subnet[*].name,
    google_compute_subnetwork.private_subnet[*].name
  )
}

output "subnet_cidr" {
  value   = concat(
    google_compute_subnetwork.public_subnet[*].ip_cidr_range,
    google_compute_subnetwork.private_subnet[*].ip_cidr_range
  )
}

output "ubuntu_name" {
	value		= concat(
    google_compute_instance.public_instance[*].name,
    google_compute_instance.private_instance[*].name
  )
}

output "ubuntu_public_ip" {
  value   = google_compute_instance.public_instance[*].network_interface.0.access_config.0.nat_ip
}

output "ubuntu_private_ip" {
  value   = concat(
    google_compute_instance.public_instance[*].network_interface.0.network_ip,
    google_compute_instance.private_instance[*].network_interface.0.network_ip
  )
}

output "ubuntu_id" {
	value		= concat(
    google_compute_instance.public_instance[*].self_link,
    google_compute_instance.private_instance[*].self_link
  )
}
