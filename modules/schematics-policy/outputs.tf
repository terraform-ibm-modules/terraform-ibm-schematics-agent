output "policy_ids" {
  description = "Schematics policy IDs"
  value = {
    for k, v in ibm_schematics_policy.policy :
    k => v.id
  }
}

output "policies" {
  description = "Schematics policy resources"
  value       = ibm_schematics_policy.policy
}
