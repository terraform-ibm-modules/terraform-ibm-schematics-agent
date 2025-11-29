############################################################################
# Resource Group
############################################################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.4.0"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

##############################################################################
# Create Cloud Object Storage instance and a bucket
##############################################################################

module "cos" {
  source                 = "terraform-ibm-modules/cos/ibm"
  version                = "10.7.0"
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
  public_gateway           = ibm_is_public_gateway.gateway.id
}

resource "ibm_is_public_gateway" "gateway" {
  name           = "${var.prefix}-gateway-1"
  vpc            = ibm_is_vpc.vpc.id
  resource_group = module.resource_group.resource_group_id
  zone           = "${var.region}-1"
}

##############################################################################
# Create a OpenShift cluster with 2 worker nodes
##############################################################################
locals {
  cluster_vpc_subnets = {
    default = [
      {
        id         = ibm_is_subnet.subnet.id
        cidr_block = ibm_is_subnet.subnet.ipv4_cidr_block
        zone       = ibm_is_subnet.subnet.zone
      }
    ]
  }

  worker_pools = [
    {
      subnet_prefix    = "default"
      pool_name        = "default"
      machine_type     = "bx2.4x16"
      workers_per_zone = 2 # minimum of 2 is allowed when using single zone
      operating_system = "RHCOS"
    }
  ]
}

module "ocp_base" {
  source               = "terraform-ibm-modules/base-ocp-vpc/ibm"
  version              = "3.73.5"
  resource_group_id    = module.resource_group.resource_group_id
  region               = var.region
  tags                 = var.resource_tags
  cluster_name         = "${var.prefix}-cluster"
  force_delete_storage = true
  vpc_id               = ibm_is_vpc.vpc.id
  vpc_subnets          = local.cluster_vpc_subnets
  worker_pools         = local.worker_pools
  # Allows outbound internet access for your workspace runs to be able to pull terraform providers from the internet. [Learn more](https://cloud.ibm.com/docs/schematics?topic=schematics-agent-infrastructure-overview#agents-infra-workspace)
  # If you want to deploy a fully private cluster, you must configure private registries so Terraform providers can be downloaded. [Learn more](https://cloud.ibm.com/docs/schematics?topic=schematics-agent-registry-overview&interface=terraform)
  disable_outbound_traffic_protection = true
}

##############################################################################
# Create and deploy the Schematics agent
##############################################################################

module "schematics_agent" {
  source                      = "../.."
  infra_type                  = "ibm_openshift"
  cluster_id                  = module.ocp_base.cluster_id
  cluster_resource_group_name = module.resource_group.resource_group_name
  cos_instance_name           = module.cos.cos_instance_name
  cos_bucket_name             = module.cos.bucket_name
  cos_bucket_region           = module.cos.bucket_region
  agent_location              = var.region
  agent_description           = "${var.prefix}-agent-description"
  agent_name                  = "${var.prefix}-agent"
  agent_resource_group_name   = module.resource_group.resource_group_name
  schematics_location         = var.region
}
