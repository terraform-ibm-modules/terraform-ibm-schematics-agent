output "agent_id" {
  description = "Schematics agent ID."
  value       = local.agent_id
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
