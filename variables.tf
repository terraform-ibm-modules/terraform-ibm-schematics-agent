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
  description = "The schematics agent version."
  nullable    = false
  default     = "1.0.1-beta"
}
