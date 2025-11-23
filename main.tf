resource "ibm_schematics_agent" "schematics_agent_instance" {
  agent_infrastructure {
    infra_type             = var.infra_type
    cluster_id             = var.cluster_id
    cluster_resource_group = var.cluster_resource_group_name
    cos_instance_name      = var.cos_instance_name
    cos_bucket_name        = var.cos_bucket_name
    cos_bucket_region      = var.cos_bucket_region
  }

  dynamic "agent_metadata" {
    for_each = var.agent_metadata
    content {
      name  = var.agent_metadata["name"]
      value = var.agent_metadata["value"]
    }
  }

  agent_location        = var.agent_location
  description           = var.agent_description
  name                  = var.agent_name
  resource_group        = var.agent_resource_group_name
  schematics_location   = var.schematics_location
  version               = var.agent_version
  tags                  = var.agent_tags
  run_destroy_resources = var.run_destroy_resources_job ? 1 : 0

  user_state {
    state = var.disable_agent ? "disable" : "enable"
  }
}

resource "ibm_schematics_agent_deploy" "schematics_agent_deploy" {
  agent_id = ibm_schematics_agent.schematics_agent_instance.id
}

data "ibm_iam_auth_token" "tokendata" {
  depends_on = [ibm_schematics_agent_deploy.schematics_agent_deploy]
}

resource "null_resource" "agent_deployment_status" {

  provisioner "local-exec" {
    command     = "${path.module}/scripts/verify_agent_status.sh"
    interpreter = ["/bin/bash", "-c"]
    environment = {
      ACCESS_TOKEN = data.ibm_iam_auth_token.tokendata.iam_access_token
      REGION       = var.agent_location
      AGENT_ID     = ibm_schematics_agent.schematics_agent_instance.id
      PRIVATE_ENV  = var.use_schematics_private_endpoint ? true : false
    }
  }
}
