##############################################################################
# Outputs
##############################################################################

output "vpc_id" {
  description = "VPC ID"
  value       = ibm_is_vpc.vpc.id
}

output "cluster_id" {
  description = "Cluster ID"
  value       = ibm_container_vpc_cluster.cluster.id
}
