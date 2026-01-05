output "agent_id" {
  description = "Schematics agent ID."
  value       = ibm_schematics_agent.schematics_agent_instance.id
}

output "agent_crn" {
  description = "Schematics agent CRN."
  value       = ibm_schematics_agent.schematics_agent_instance.agent_crn
}

output "log_url" {
  description = "URL to the full schematics agent deployment job logs."
  value       = ibm_schematics_agent_deploy.schematics_agent_deploy.log_url
}

output "status_code" {
  description = "Final result of the schematics agent deployment job."
  value       = ibm_schematics_agent_deploy.schematics_agent_deploy.status_code
}

output "status_message" {
  description = "The outcome of the schematics agent deployment job, in a formatted log string."
  value       = ibm_schematics_agent_deploy.schematics_agent_deploy.status_message
}

output "schematics_policies_metadata" {
  description = "Schematics agent policies metadata."
  value       = module.schematics_policy.policies
}
