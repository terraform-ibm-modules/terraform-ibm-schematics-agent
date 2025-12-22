output "cluster_id" {
  description = "OpenShift cluster ID."
  value       = module.ocp_base.cluster_id
}

output "schematics_agent_id" {
  description = "Schematics agent ID."
  value       = module.schematics_agent.agent_id
}

output "schematics_agent_crn" {
  description = "Schematics agent CRN."
  value       = module.schematics_agent.agent_crn
}

output "schematics_agent_job_log_url" {
  description = "URL to the full schematics agent deployment job logs."
  value       = module.schematics_agent.log_url
}

output "schematics_agent_status_code" {
  description = "Final result of the schematics agent deployment job."
  value       = module.schematics_agent.status_code
}

output "schematics_agent_status_message" {
  description = "The outcome of the schematics agent deployment job, in a formatted log string."
  value       = module.schematics_agent.status_message
}

output "agent_policies_metadata" {
  description = "Schematic Agent policies metadata."
  value       = module.schematics_agent.schematics_policies_metadata
}
