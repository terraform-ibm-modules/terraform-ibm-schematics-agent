############################################################################
# Resource Group
############################################################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.1.6"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

##############################################################################
# Create Cloud Object Storage instance and a bucket
##############################################################################

module "cos" {
  source                 = "terraform-ibm-modules/cos/ibm"
  version                = "8.21.6"
  resource_group_id      = module.resource_group.resource_group_id
  region                 = var.region
  cos_instance_name      = "${var.prefix}-cos"
  cos_tags               = var.resource_tags
  bucket_name            = "${var.prefix}-bucket"
  retention_enabled      = false # disable retention for test environments - enable for stage/prod
  kms_encryption_enabled = false
}

##############################################################################
# VPC
##############################################################################

resource "ibm_is_vpc" "vpc" {
  name           = "${var.prefix}-vpc"
  resource_group = module.resource_group.resource_group_id
  tags           = var.resource_tags
}

resource "ibm_is_subnet" "subnet" {
  name                     = "${var.prefix}-subnet"
  vpc                      = ibm_is_vpc.vpc.id
  zone                     = "${var.region}-1"
  total_ipv4_address_count = 256
  resource_group           = module.resource_group.resource_group_id
}

##############################################################################
# Create a Kubernetes cluster with 3 worker nodes
##############################################################################

resource "ibm_container_vpc_cluster" "cluster" {
  name              = "${var.prefix}-cluster"
  vpc_id            = ibm_is_vpc.vpc.id
  flavor            = "bx2.4x16"
  resource_group_id = module.resource_group.resource_group_id
  worker_count      = 3
  zones {
    subnet_id = ibm_is_subnet.subnet.id
    name      = "${var.region}-1"
  }
}

##############################################################################
# Create and deploy the Schematics agent
##############################################################################

module "schematics_agent" {
  source                    = "../../"
  infra_type                = "ibm_kubernetes"
  cluster_id                = ibm_container_vpc_cluster.cluster.id
  cluster_resource_group_id = module.resource_group.resource_group_name
  cos_instance_name         = module.cos.cos_instance_name
  cos_bucket_name           = module.cos.bucket_name
  cos_bucket_region         = module.cos.bucket_region
  agent_location            = var.region
  agent_description         = "${var.prefix}-agent-description"
  agent_name                = "${var.prefix}-agent"
  agent_resource_group_id   = module.resource_group.resource_group_id
  schematics_location       = var.region # Allowed values are `us-south`, `us-east`, `eu-gb`, `eu-de`.
  agent_version             = var.agent_version
}
