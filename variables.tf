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
  description = "The COS instance name where the bucket is created for the schematics agent logs."
  nullable    = false
}

variable "cos_bucket_name" {
  type        = string
  description = "The COS bucket name to store the schematics agent logs."
  nullable    = false
}

variable "cos_bucket_region" {
  type        = string
  description = "The COS bucket region."
  nullable    = false
}

variable "agent_location" {
  type        = string
  description = "The location where the schematics agent is deployed in the user environment."
  default     = "us-south"
  nullable    = false
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
  description = "The resource group ID of the schematics resource group."
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
}

# Agent Policy
variable "create_agent_policy" {
  type        = bool
  description = "Flag when set to True creates schematics agent policy."
  default     = false
}

variable "agent_policy_name" {
  type        = string
  description = "Name of the schematics agent policy."
  default     = null
}

variable "agent_policy_description" {
  type        = string
  description = "The schematics agent policy description."
  default     = null
}

variable "agent_policy_kind" {
  type        = string
  description = "The schematics agent policy for job execution. Acceptable values: `agent_assignment_policy`."
  default     = "agent_assignment_policy"
  validation {
    condition     = var.agent_policy_kind == "agent_assignment_policy"
    error_message = "'var.agent_policy_kind' can only be set as 'agent_assignment_policy'."
  }
}

variable "agent_policy_resource_group_id" {
  type        = string
  description = "The resource group ID of the schematics agents policy resource group."
  default     = "Default"
}

variable "agent_policy_selector_kind" {
  description = "Way to target the schematics agent from the policy."
  type        = string
  default     = "ids"
  validation {
    condition     = contains(["ids", "scoped"], var.agent_policy_selector_kind)
    error_message = "'agent_policy_selector_kind' must be either 'ids' or 'scoped'."
  }
}

# TODO: Add "scoped" for the "agent_policy_selector_kind"
