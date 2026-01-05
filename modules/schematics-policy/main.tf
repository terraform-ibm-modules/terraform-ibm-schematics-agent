resource "ibm_schematics_policy" "policy" {
  for_each = var.schematics_policies

  name           = each.value.name
  description    = try(each.value.description, null)
  kind           = "agent_assignment_policy" # Only allowable value is agent_assignment_policy
  location       = try(each.value.location, null)
  resource_group = try(each.value.resource_group, null)
  tags           = try(each.value.tags, null)

  dynamic "scoped_resources" {
    for_each = try(each.value.scoped_resources, [])
    content {
      id   = try(scoped_resources.value.id, null)
      kind = try(scoped_resources.value.kind, null)
    }
  }

  dynamic "target" {
    for_each = try(each.value.target, [])
    content {
      selector_kind = try(target.value.selector_kind, null)
      selector_ids  = try(target.value.selector_ids, null)

      dynamic "selector_scope" {
        for_each = try(target.value.selector_scope, [])
        content {
          kind            = try(selector_scope.value.kind, null)
          locations       = try(selector_scope.value.locations, null)
          resource_groups = try(selector_scope.value.resource_groups, null)
          tags            = try(selector_scope.value.tags, null)
        }
      }
    }
  }

  dynamic "parameter" {
    for_each = try(each.value.parameter, [])
    content {
      dynamic "agent_assignment_policy_parameter" {
        for_each = try(parameter.value.agent_assignment_policy_parameter, [])
        content {
          selector_kind = try(agent_assignment_policy_parameter.value.selector_kind, null)
          selector_ids  = try(agent_assignment_policy_parameter.value.selector_ids, null)

          dynamic "selector_scope" {
            for_each = try(agent_assignment_policy_parameter.value.selector_scope, [])
            content {
              kind            = try(selector_scope.value.kind, null)
              locations       = try(selector_scope.value.locations, null)
              resource_groups = try(selector_scope.value.resource_groups, null)
              tags            = try(selector_scope.value.tags, null)
            }
          }
        }
      }
    }
  }
}
