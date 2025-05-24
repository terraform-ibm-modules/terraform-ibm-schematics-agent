# Kubernetes example

An end-to-end example that will provision the following:
* A new resource group if one is not passed in.
* A COS instance and a bucket.
* A Public Gateway resource.
* A new VPC with 1 subnet with Public Gateway attached to the subnet.
* An IBM VPC Gen2 Kubernetes cluster with 3 worker nodes and flavor "bx2.4x16". (**Note**: The outbound traffic protection is disabled for the pod to allow internet access for downloading terraform provider for the agent.)
* Creates and deploy the Schematics' agent on the Kubernetes cluster.
