resource "ibm_schematics_agent" "schematics_agent_instance" {
  agent_infrastructure {
    infra_type             = "ibm_kubernetes" #ibm_openshift
    cluster_id             = "cnjiigvd0r63r6c1grt0"
    cluster_resource_group = "rajat-iks2-resource-group"
    cos_instance_name      = "rajat-iks2-cos"
    cos_bucket_name        = "rajat-iks2-bucket"
    cos_bucket_region      = "us-south"
  }
  agent_location      = "us-south"
  description         = "Schemetics agent"
  name                = "Rajat-schemetics-agent-12"
  resource_group      = var.resource_group_id
  schematics_location = "us-south"
  version             = "1.0.1-beta"
}

locals {
  agent_id = join(".", slice(split(":", ibm_schematics_agent.schematics_agent_instance.agent_crn), 9, 10))
}

resource "ibm_schematics_agent_deploy" "schematics_agent_deploy" {
  agent_id = local.agent_id
}
