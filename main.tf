resource "ibm_schematics_agent" "schematics_agent_instance" {
  agent_infrastructure {
    infra_type             = var.infra_type
    cluster_id             = var.cluster_id
    cluster_resource_group = var.cluster_resource_group_id
    cos_instance_name      = var.cos_instance_name
    cos_bucket_name        = var.cos_bucket_name
    cos_bucket_region      = var.cos_bucket_region
  }
  agent_location      = var.agent_location
  description         = var.agent_description
  name                = var.agent_name
  resource_group      = var.agent_resource_group_id
  schematics_location = var.schematics_location
  version             = var.agent_version
}

resource "ibm_schematics_agent_deploy" "schematics_agent_deploy" {
  agent_id = ibm_schematics_agent.schematics_agent_instance.id
}

resource "ibm_schematics_policy" "schematics_agent_policy" {
  count = var.create_agent_policy ? 1 : 0

  # Schematics Agent Policy parameters
  name           = var.agent_policy_name
  description    = var.agent_policy_description
  kind           = var.agent_policy_kind
  location       = var.agent_location
  resource_group = var.agent_policy_resource_group_id
  tags           = ["policy", "test"]

  # Schematics agent parameters
  target {
    selector_kind = var.agent_policy_selector_kind
    selector_ids  = [ibm_schematics_agent.schematics_agent_instance.id]
  }

  # Schematics workspace/actions parameters
  parameter {
    agent_assignment_policy_parameter {
      selector_kind = "scoped"

      selector_scope {
        kind            = "workspace"
        locations       = ["us-south"]
        tags            = ["reg:us-south", "rg:r-sa-pol-resource-group"]
        resource_groups = ["r-sa-pol-resource-group"]
      }
    }
  }
}

data "ibm_schematics_policy" "schematics_policy_instance" {
  count     = var.create_agent_policy ? 1 : 0
  policy_id = ibm_schematics_policy.schematics_agent_policy[0].id
}
