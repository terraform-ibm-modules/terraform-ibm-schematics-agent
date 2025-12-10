# Kubernetes example

An end-to-end example that will provision the following:
* A new resource group if one is not passed in.
* A COS instance and a bucket.
* A new VPC with 1 subnet.
* An IBM VPC Gen2 Kubernetes cluster with 3 worker nodes and flavor "bx2.4x16".
* Creates and deploy the Schematics' agent on the Kubernetes cluster.
* Creates Schematics Agent policy and bind that with the workspace.

**Temporary Note:** Currently in the UI it doesn't show the correct target workspace resource group. It shows workspaces within the `"Default"` resource group. But in the Terraform state file, it shows the correct target workspace resource group. Open issue: https://github.ibm.com/blueprint/product/issues/12888
