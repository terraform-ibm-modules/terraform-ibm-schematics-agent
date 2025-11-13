variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API Key."
  sensitive   = true
}

variable "region" {
  type        = string
  description = "Region to provision all resources created by this example"
  default     = "us-south"
}

variable "prefix" {
  type        = string
  description = "Prefix to append to all resources created by this example"
  default     = "sa-k8s"
}

variable "resource_group" {
  type        = string
  description = "An existing resource group name to use for this example, if unset a new resource group will be created"
  default     = "Default"
}

variable "resource_tags" {
  type        = list(string)
  description = "Optional list of tags to be added to created resources"
  default     = []
}

variable "agent_location" {
  type        = string
  description = "The location where the schematics agent is deployed in the user environment."
  default     = "us-south"
  nullable    = false
}

variable "agent_version" {
  type        = string
  description = "The schematics agent version. More info: https://cloud.ibm.com/docs/schematics?topic=schematics-update-agent-overview&interface=ui#agent_version-releases"
  default     = "1.5.0"
}

variable "agent_metadata_name" {
  type        = string
  description = "(Optional) The metadata name of the agent."
  default     = "Purpose"
}

variable "agent_metadata_value" {
  type        = list(string)
  description = "(Optional) The value of the metadata name of the agent."
  default     = ["git", "terraform"]
}

variable "agent_tags" {
  type        = list(string)
  description = "Optional list of tags to be added to the agent."
  default     = []
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
}
