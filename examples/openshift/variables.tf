variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API Key."
  sensitive   = true
}

variable "region" {
  type        = string
  description = "Region to provision all resources created by this example."
  default     = "us-south"
}

variable "prefix" {
  type        = string
  description = "Prefix to append to all resources created by this example."
  default     = "sa-ocp"
}

variable "resource_group" {
  type        = string
  description = "An existing resource group name to use for this example, if unset a new resource group will be created."
  default     = null
}

variable "resource_tags" {
  type        = list(string)
  description = "The list of tags to be added to created resources."
  default     = []
}

variable "private_only_cluster" {
  type        = bool
  description = "Set to true to deploy a private-only cluster without a public gateway and with outbound traffic protection enabled. Public access is NOT required to install the Schematics agent - IBM Cloud services (Schematics, COS) remain accessible via private endpoints. However, if your Terraform configurations pull modules or providers from the public internet, the cluster will need internet access or you must configure private registries/proxies. Learn more: https://cloud.ibm.com/docs/schematics?topic=schematics-agent-registry-overview"
  default     = false
}
