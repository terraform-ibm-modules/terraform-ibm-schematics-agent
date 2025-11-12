# Kubernetes example

An end-to-end example that will provision the following:
* A new resource group if one is not passed in.
* A COS instance and a bucket.
* A new VPC with 1 subnet.
* An IBM VPC Gen2 Kubernetes cluster with 3 worker nodes and flavor "bx2.4x16".
* Creates and deploy the Schematics' agent on the Kubernetes cluster.
