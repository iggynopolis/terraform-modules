
variable "vpc_count" {
  type        = number
  description = "Number of VPCs to create."
}

variable "resource_name_label" {
  type        = string
  description = "Label name for all resources."
}

variable "pub_subnet" {
  type        = string
  description = "Public subnet."
}

variable "pri_subnet" {
  type        = string
  description = "Private subnet"
}

variable "pub_instance_zone" {
  type        = string
  description = "GCP zone to launch public instance."
}

variable "pri_instance_zone" {
  type        = string
  description = "GCP zone to launch private instance."
}

variable "pub_hostnum" {
  type        = number
  description = "Private hostpart of the public Ubuntu instance."
}

variable "pri_hostnum" {
  type        = number
  description = "Private hostnum of the private Ubuntu instance."
}

variable "public_key" {
  type        = string
  description = "Public key to ssh into Ubuntu instances."
}
