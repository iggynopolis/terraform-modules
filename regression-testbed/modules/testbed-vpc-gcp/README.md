## Regression Testbed Terraform

### Description

This Terraform configuration creates an GCP test environment. Includes VPC, subnet, firewall, public instance, private instance.

### Prerequisites

- Have Aviatrix IAM roles
- Google Cloud Project created
- GCP Credentials file
- existing SSH Key

### Usage
```
module "testbed-gcp" {
  source = "<<path to module>>"

  vpc_count             = 1
  resource_name_label   = "regression"
  pub_subnet            = "10.20.0.0/24"
  pri_subnet            = "10.30.0.0/24"
  pub_instance_zone     = "us-central1-a"
  pri_instance_zone     = "us-central1-b"
  pub_hostnum           = 20
  pri_hostnum           = 40
  public_key            = <<public_key>>
}
```

### Variables
- **vpc_count**

Number of VPCs to create.

- **resource_name_label**

Label name for all the resources.

- **pub_subnet**

Public subnet.

- **pri_subnet**

Private subnet.

- **pub_instance_zone**

GCP zone to launch public instance.

- **pri_instance_zone**

GCP zone to launch private instance.

- **pub_hostnum**

Private hostpart of the public Ubuntu instance.

- **pri_hostnum**

Private hostnum of the private Ubuntu instance.

### Outputs

- **vpc_id**

VPC URI.

- **vpc_name**

VPC Name.

- **subnet_name**

Names of the subnets in the VPC.

- **subnet_cidr**

Cidr of the subnets in the VPC.

- **ubuntu_name**

Name of the Ubuntu instances.

- **ubuntu_public_ip**

Public IP of the public Ubuntu instance.

- **ubuntu_private_ip**

Private IP of the Ubuntu instances.

- **ubuntu_id**

Instance URI of the Ubuntu instances.
