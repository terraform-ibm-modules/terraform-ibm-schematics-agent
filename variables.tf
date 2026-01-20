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
  description = "The schematics agent version. More info: https://cloud.ibm.com/docs/schematics?topic=schematics-update-agent-overview&interface=ui#agent_version-releases"
  nullable    = false
  default     = "1.6.0"

  validation {
    condition     = contains(["1.6.0", "1.5.0", "1.4.0", "1.3.1", "1.3.0", "1.2.0", "1.1.1", "1.1.0", "1.0.0", ], var.agent_version)
    error_message = "Agent version provided is not supported."
  }
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

variable "schematics_policies" {
  description = "Schematics agent policies to create"
  type = map(object({
    name           = string
    description    = optional(string)
    location       = optional(string)
    resource_group = optional(string)
    tags           = optional(list(string), [])

    scoped_resources = optional(list(object({
      id   = optional(string)
      kind = optional(string)
    })), [])

    target = optional(list(object({
      selector_kind = optional(string)
      selector_ids  = optional(list(string))
      selector_scope = optional(list(object({
        kind            = optional(string)
        locations       = optional(list(string))
        resource_groups = optional(list(string))
        tags            = optional(list(string))
      })), [])
    })), [])

    parameter = optional(list(object({
      agent_assignment_policy_parameter = optional(list(object({
        selector_kind = optional(string)
        selector_ids  = optional(list(string))
        selector_scope = optional(list(object({
          kind            = optional(string)
          locations       = optional(list(string))
          resource_groups = optional(list(string))
          tags            = optional(list(string))
        })), [])
      })), [])
    })), [])
  }))
  default = {}

  validation {
    condition = alltrue([
      for _, p in var.schematics_policies : (
      try(p.location, null) == null || contains(["us-south", "us-east", "eu-gb", "eu-de", "ca-mon", "ca-tor", "eu-fr2"], try(p.location, null)))
    ])
    error_message = "Invalid Schematics policy location. Allowed values are: us-south, us-east, eu-gb, eu-de, ca-mon, ca-tor, eu-fr2."
  }

  validation {
    condition = alltrue([
      for _, p in var.schematics_policies : alltrue([
        for param in try(p.parameter, []) : alltrue([
          for ap in try(param.agent_assignment_policy_parameter, []) : (
            try(ap.selector_kind, null) == null || contains(["ids", "scoped"], try(ap.selector_kind, null))
          )
        ])
      ])
    ])
    error_message = "Invalid selector_kind in agent_assignment_policy_parameter. Allowed values are: ids, scoped."
  }

  validation {
    condition = alltrue([
      for _, p in var.schematics_policies : alltrue([
        for param in try(p.parameter, []) : alltrue([
          for ap in try(param.agent_assignment_policy_parameter, []) : alltrue([
            for scope in try(ap.selector_scope, []) : (
              try(scope.kind, null) == null || contains(["workspace", "action", "system", "environment", "blueprint"], try(scope.kind, null)
              )
          )])
        ])
      ])
    ])
    error_message = "Invalid selector_scope.kind in agent_assignment_policy_parameter. Allowed values are: workspace, action, system, environment, blueprint."
  }

  validation {
    condition = alltrue([
      for _, p in var.schematics_policies : alltrue([
        for param in try(p.parameter, []) : alltrue([
          for ap in try(param.agent_assignment_policy_parameter, []) : alltrue([
            for scope in try(ap.selector_scope, []) : alltrue([
              for loc in try(scope.locations, []) :
              contains(["us-south", "us-east", "eu-gb", "eu-de", "ca-mon", "ca-tor", "eu-fr2"], loc)
            ])
          ])
        ])
      ])
    ])
    error_message = "Invalid selector_scope.locations in agent_assignment_policy_parameter. Allowed values are: us-south, us-east, eu-gb, eu-de, ca-mon, ca-tor, eu-fr2."
  }

  validation {
    condition = alltrue([
      for _, p in var.schematics_policies : alltrue([
        for sr in try(p.scoped_resources, []) : (
          try(sr.kind, null) == null || contains(["workspace", "action", "system", "environment", "blueprint"], try(sr.kind, null)
          )
        )
      ])
    ])
    error_message = "Invalid scoped_resources.kind. Allowed values are: workspace, action, system, environment, blueprint."
  }

  validation {
    condition = alltrue([
      for _, p in var.schematics_policies : alltrue([
        for t in try(p.target, []) : (
          try(t.selector_kind, null) == null || contains(["ids", "scoped"], try(t.selector_kind, null)
          )
        )
      ])
    ])
    error_message = "Invalid target.selector_kind. Allowed values are: ids, scoped."
  }

  validation {
    condition = alltrue([
      for _, p in var.schematics_policies : alltrue([
        for t in try(p.target, []) : alltrue([
          for scope in try(t.selector_scope, []) : (
            try(scope.kind, null) == null || contains(["workspace", "action", "system", "environment", "blueprint"], try(scope.kind, null)
            )
          )
        ])
      ])
    ])
    error_message = "Invalid target.selector_scope.kind. Allowed values are: workspace, action, system, environment, blueprint."
  }

  validation {
    condition = alltrue([
      for _, p in var.schematics_policies : alltrue([
        for t in try(p.target, []) : alltrue([
          for scope in try(t.selector_scope, []) : alltrue([
            for loc in try(scope.locations, []) :
            contains(["us-south", "us-east", "eu-gb", "eu-de", "ca-mon", "ca-tor", "eu-fr2"], loc)
          ])
        ])
      ])
    ])
    error_message = "Invalid target.selector_scope.locations. Allowed values are: us-south, us-east, eu-gb, eu-de, ca-mon, ca-tor, eu-fr2."
  }
}

variable "install_required_binaries" {
  type        = bool
  default     = true
  description = "When set to true, a script will run to check if `jq` exist on the runtime and if not attempt to download them from the public internet and install them to /tmp. Set to false to skip running this script."
  nullable    = false
}
