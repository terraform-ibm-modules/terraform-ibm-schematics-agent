variable "infra_type" {
  type        = string
  description = "Type of target agent infrastructure. Allowed values: `ibm_kubernetes`, `ibm_openshift` and `ibm_satellite`."
  default     = "ibm_kubernetes"
  validation {
    condition     = contains(["ibm_kubernetes", "ibm_openshift", "ibm_satellite"], var.infra_type)
    error_message = "Allowed values for `infra_type` are \"ibm_kubernetes\", \"ibm_openshift\" and \"ibm_satellite\"."
  }
}

variable "cluster_id" {
  type        = string
  description = "ID of the target cluster where the schematics agent will be installed."
  nullable    = false
}

variable "cluster_resource_group_name" {
  type        = string
  description = "The resource group name of the target cluster where the schematics agent will be installed."
  nullable    = false
}

variable "cos_instance_name" {
  type        = string
  description = "The Object Storage instance name where the bucket is created for the schematics agent logs."
  nullable    = false
}

variable "cos_bucket_name" {
  type        = string
  description = "The Object Storage bucket name to store the schematics agent logs."
  nullable    = false
}

variable "cos_bucket_region" {
  type        = string
  description = "The Object Storage bucket region."
  nullable    = false
}

variable "agent_location" {
  type        = string
  description = "The location where the schematics agent is deployed in the user environment."
  default     = "us-south"
  nullable    = false

  validation {
    condition     = contains(["us-south", "us-east", "eu-gb", "eu-de", "ca-mon", "eu-fr2", "ca-tor"], var.agent_location)
    error_message = "Allowed values for `agent_location` are \"us-south\", \"us-east\", \"eu-gb\", \"eu-de\", \"ca-mon\", \"eu-fr2\" or \"ca-tor\"."
  }
}

variable "agent_description" {
  type        = string
  description = "The schematics agent description."
  default     = null
}

variable "agent_name" {
  type        = string
  description = "The schematics agent name."
  nullable    = false
}

variable "agent_resource_group_name" {
  type        = string
  description = "The resource group name for the schematics agent."
  nullable    = false
}

variable "schematics_location" {
  type        = string
  description = "The location to create the Schematics workspace. Allowed values are `us-south`, `us-east`, `eu-gb`, `eu-de`, `ca-tor`, `ca-mon`, `eu-fr2`."
  default     = "us-south"
  validation {
    condition     = contains(["us-south", "us-east", "eu-gb", "eu-de", "ca-tor", "ca-mon", "eu-fr2"], var.schematics_location)
    error_message = "Allowed values for `schematics_location` are \"us-south\", \"us-east\", \"eu-gb\", \"ca-tor\", \"ca-mon\", \"eu-fr2\" or \"eu-de\"."
  }
}

variable "use_schematics_private_endpoint" {
  type        = bool
  description = "Set to `true` to use IBM Cloud Schematics private endpoints. Requires the runtime to have access to the IBM Cloud private network."
  default     = false
}

variable "agent_version" {
  type        = string
  description = "The schematics agent version. If not specified (null), the latest supported version is used. More info: https://cloud.ibm.com/docs/schematics?topic=schematics-update-agent-overview&interface=ui#agent_version-releases"
  default     = null
}

# See, https://github.com/IBM-Cloud/terraform-provider-ibm/issues/6569
# variable "agent_metadata" {
#   type = object({
#     name  = optional(string)
#     value = optional(list(string))
#   })
#   description = "The metadata of the agent."
#   default     = {}
# }

variable "agent_tags" {
  type        = list(string)
  description = "The list of tags to be added to the agent."
  default     = []
}

variable "run_destroy_resources_job" {
  type        = bool
  description = "Set this value to `false` if you do not want to destroy resources associated with the agent deployment. Defaults to `true`."
  default     = true
}

variable "disable_agent" {
  type        = bool
  description = "User defined status of the agent. Set to `true` to disable the agent. By default the agent state will be enabled."
  default     = false
}
