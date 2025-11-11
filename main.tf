resource "ibm_schematics_agent" "schematics_agent_instance" {
  agent_infrastructure {
    infra_type             = var.infra_type
    cluster_id             = var.cluster_id
    cluster_resource_group = var.cluster_resource_group_id
    cos_instance_name      = var.cos_instance_name
    cos_bucket_name        = var.cos_bucket_name
    cos_bucket_region      = var.cos_bucket_region
  }
  agent_metadata {
    name  = var.agent_metadata_name
    value = var.agent_metadata_value
  }
  agent_location        = var.agent_location
  description           = var.agent_description
  name                  = var.agent_name
  resource_group        = var.agent_resource_group_id
  schematics_location   = var.schematics_location
  version               = var.agent_version
  tags                  = var.agent_tags
  run_destroy_resources = var.run_destroy_resources
  user_state {
    state = var.agent_state
  }
}

resource "ibm_schematics_agent_deploy" "schematics_agent_deploy" {
  agent_id = ibm_schematics_agent.schematics_agent_instance.id
}
