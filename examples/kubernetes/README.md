# Kubernetes example

An end-to-end example that will provision the following:
* A new resource group if one is not passed in.
* An Object Storage instance and a bucket.
* A new VPC with one subnet.
* An IBM VPC Gen2 Kubernetes cluster with 3 worker nodes and flavor "bx2.2x8".
* Creates and deploy the Schematics agent on the cluster.
