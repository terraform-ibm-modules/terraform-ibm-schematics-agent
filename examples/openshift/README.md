# OpenShift example

An end-to-end example that provisions the following:
* A new resource group if one is not passed in.
* An Object Storage instance and a bucket.
* A basic VPC and subnet with public gateway enabled.
* An IBM VPC Gen2 OpenShift cluster with 3 worker nodes and flavor "bx2.4x16".
* Creates and deploy the Schematics agent on the cluster.
* Creates the Schematics agent policy for the agent and bind it with the Terraform workspace.
