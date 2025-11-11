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

variable "cluster_resource_group_id" {
  type        = string
  description = "Resource group ID of the target cluster where the schematics agent will be installed."
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

variable "agent_resource_group_id" {
  type        = string
  description = "The resource group ID for the schematics agent."
  nullable    = false
}

variable "schematics_location" {
  type        = string
  description = "List of locations supported by IBM Cloud Schematics service. Allowed values are `us-south`, `us-east`, `eu-gb`, `eu-de`."
  default     = "us-south"
  validation {
    condition     = contains(["us-south", "us-east", "eu-gb", "eu-de"], var.schematics_location)
    error_message = "Allowed values for `schematics_location` are \"us-south\", \"us-east\", \"eu-gb\" or \"eu-de\"."
  }
}

variable "agent_version" {
  type        = string
  description = "The schematics agent version. More info: https://cloud.ibm.com/docs/schematics?topic=schematics-update-agent-overview&interface=ui#agent_version-releases"
  nullable    = false
  default     = "1.5.0"

  validation {
    condition     = contains(["1.5.0", "1.4.0", "1.3.1", "1.3.0", "1.2.0", "1.1.1", "1.1.0", "1.0.0", ], var.agent_version)
    error_message = "Agent version provided is not supported."
  }
}

variable "agent_metadata_name" {
  type        = string
  description = "(Optional) The metadata name of the agent."
  default     = null
}

variable "agent_metadata_value" {
  type        = list(string)
  description = "(Optional) The value of the metadata name of the agent."
  default     = null
}

variable "agent_tags" {
  type        = list(string)
  description = "Optional list of tags to be added to the agent."
  default     = null
}

variable "run_destroy_resources" {
  type        = number
  description = "Set this value greater than zero to destroy resources associated with agent deployment."
  default     = 0
}

variable "agent_state" {
  type        = string
  description = "User defined status of the agent. Allowed values are: `enable`, `disable`."
  default     = "enable"

  validation {
    condition     = contains(["enable", "disable"], var.agent_state)
    error_message = "Allowed values for agent_state are: `enable` and `disable`."
  }
}
