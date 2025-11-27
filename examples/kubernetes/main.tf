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
  version                = "10.5.9"
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
# Create a Kubernetes cluster with 3 worker nodes
##############################################################################

resource "ibm_container_vpc_cluster" "cluster" {
  name              = "${var.prefix}-cluster"
  vpc_id            = ibm_is_vpc.vpc.id
  flavor            = "bx2.4x16"
  resource_group_id = module.resource_group.resource_group_id
  worker_count      = 2
  zones {
    subnet_id = ibm_is_subnet.subnet.id
    name      = "${var.region}-1"
  }
  wait_till = "IngressReady"
  # Allows outbound internet access for your workspace runs to be able to pull terraform providers from the internet. [Learn more](https://cloud.ibm.com/docs/schematics?topic=schematics-agent-infrastructure-overview#agents-infra-workspace)
  # If you want to deploy a fully private cluster, you must configure private registries so Terraform providers can be downloaded. [Learn more](https://cloud.ibm.com/docs/schematics?topic=schematics-agent-registry-overview&interface=terraform)
  disable_outbound_traffic_protection = true
}

data "ibm_container_cluster_config" "cluster_config" {
  cluster_name_id   = ibm_container_vpc_cluster.cluster.id
  resource_group_id = module.resource_group.resource_group_id
}

# Sleep to allow RBAC sync on cluster
resource "time_sleep" "wait_operators" {
  depends_on      = [data.ibm_container_cluster_config.cluster_config]
  create_duration = "60s"
}
##############################################################################
# Create and deploy the Schematics agent
##############################################################################

module "schematics_agent" {
  depends_on                  = [time_sleep.wait_operators]
  source                      = "../.."
  infra_type                  = "ibm_kubernetes"
  cluster_id                  = ibm_container_vpc_cluster.cluster.id
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
