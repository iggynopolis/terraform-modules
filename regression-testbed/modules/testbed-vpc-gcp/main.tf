# Terraform configuration file to set up a GCP environment

resource "google_compute_network" "vpc" {
  count                   = var.vpc_count
  name                    = "${var.resource_name_label}-vpc${count.index}"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "public_subnet" {
  count         = var.vpc_count
  name          = "${var.resource_name_label}-public-subnet${count.index}"
  ip_cidr_range = var.pub_subnet
#  region        = var.pub_subnet_region
  network       = google_compute_network.vpc[count.index].self_link
}

resource "google_compute_subnetwork" "private_subnet" {
  count         = var.vpc_count
  name          = "${var.resource_name_label}-private-subnet${count.index}"
  ip_cidr_range = var.pri_subnet
#  region        = var.pri_subnet_region
  network       = google_compute_network.vpc[count.index].self_link
}

resource "google_compute_firewall" "firewall" {
  count         = var.vpc_count
  name          = "${var.resource_name_label}-firewall${count.index}"
  network       = google_compute_network.vpc[count.index].self_link
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "icmp"
  }

  allow {
    #SSH
    protocol = "tcp"
    ports    = ["22"]
  }
}

resource "google_compute_instance" "public_instance" {
  count         = var.vpc_count
  name          = "${var.resource_name_label}-public-instance${count.index}"
  machine_type  = "f1-micro"
  zone          = var.pub_instance_zone

  boot_disk {
    initialize_params {
      image = "ubuntu-1804-lts"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.public_subnet[count.index].self_link
    network_ip = cidrhost(google_compute_subnetwork.public_subnet[count.index].ip_cidr_range, var.pub_hostnum)

    access_config {
    }
  }

  metadata = {
    ssh-keys = var.public_key
  }
}

resource "google_compute_instance" "private_instance" {
  count         = var.vpc_count
  name          = "${var.resource_name_label}-private-instance${count.index}"
  machine_type  = "f1-micro"
  zone          = var.pri_instance_zone

  boot_disk {
    initialize_params {
      image = "ubuntu-1804-lts"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.private_subnet[count.index].self_link
    network_ip = cidrhost(google_compute_subnetwork.private_subnet[count.index].ip_cidr_range, var.pri_hostnum)
  }

  metadata = {
    ssh-keys = var.public_key
  }
}
