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
    condition = alltrue(flatten([
      for _, p in var.schematics_policies : [
        for param in try(p.parameter, []) : [
          for ap in try(param.agent_assignment_policy_parameter, []) : (
            try(ap.selector_kind, null) == null || contains(["ids", "scoped"], try(ap.selector_kind, null))
          )
        ]
      ]
      ])
    )
    error_message = "Invalid selector_kind in agent_assignment_policy_parameter. Allowed values are: ids, scoped."
  }

  validation {
    condition = alltrue(flatten([
      for _, p in var.schematics_policies : [
        for param in try(p.parameter, []) : [
          for ap in try(param.agent_assignment_policy_parameter, []) : [
            for scope in try(ap.selector_scope, []) : (
              try(scope.kind, null) == null || contains(["workspace", "action", "system", "environment", "blueprint"], try(scope.kind, null)
              )
          )]
        ]
      ]
      ])
    )
    error_message = "Invalid selector_scope.kind in agent_assignment_policy_parameter. Allowed values are: workspace, action, system, environment, blueprint."
  }

  validation {
    condition = alltrue(flatten([
      for _, p in var.schematics_policies : [
        for param in try(p.parameter, []) : [
          for ap in try(param.agent_assignment_policy_parameter, []) : [
            for scope in try(ap.selector_scope, []) : alltrue([
              for loc in try(scope.locations, []) :
              contains(["us-south", "us-east", "eu-gb", "eu-de", "ca-mon", "ca-tor", "eu-fr2"], loc)
            ])
          ]
        ]
      ]
    ]))
    error_message = "Invalid selector_scope.locations in agent_assignment_policy_parameter. Allowed values are: us-south, us-east, eu-gb, eu-de, ca-mon, ca-tor, eu-fr2."
  }

  validation {
    condition = alltrue(flatten([
      for _, p in var.schematics_policies : [
        for sr in try(p.scoped_resources, []) : (
          try(sr.kind, null) == null || contains(["workspace", "action", "system", "environment", "blueprint"], try(sr.kind, null)
          )
        )
      ]
    ]))
    error_message = "Invalid scoped_resources.kind. Allowed values are: workspace, action, system, environment, blueprint."
  }

  validation {
    condition = alltrue(flatten([
      for _, p in var.schematics_policies : [
        for t in try(p.target, []) : (
          try(t.selector_kind, null) == null || contains(["ids", "scoped"], try(t.selector_kind, null)
          )
        )
      ]
    ]))
    error_message = "Invalid target.selector_kind. Allowed values are: ids, scoped."
  }

  validation {
    condition = alltrue(flatten([
      for _, p in var.schematics_policies : [
        for t in try(p.target, []) : [
          for scope in try(t.selector_scope, []) : (
            try(scope.kind, null) == null || contains(["workspace", "action", "system", "environment", "blueprint"], try(scope.kind, null)
            )
          )
        ]
      ]
    ]))
    error_message = "Invalid target.selector_scope.kind. Allowed values are: workspace, action, system, environment, blueprint."
  }

  validation {
    condition = alltrue(flatten([
      for _, p in var.schematics_policies : [
        for t in try(p.target, []) : [
          for scope in try(t.selector_scope, []) : alltrue([
            for loc in try(scope.locations, []) :
            contains(["us-south", "us-east", "eu-gb", "eu-de", "ca-mon", "ca-tor", "eu-fr2"], loc)
          ])
        ]
      ]
      ])
    )
    error_message = "Invalid target.selector_scope.locations. Allowed values are: us-south, us-east, eu-gb, eu-de, ca-mon, ca-tor, eu-fr2."
  }
}
