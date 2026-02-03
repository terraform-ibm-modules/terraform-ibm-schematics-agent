# Kubernetes example

<!-- BEGIN SCHEMATICS DEPLOY HOOK -->
<a href="https://cloud.ibm.com/schematics/workspaces/create?workspace_name=schematics-agent-kubernetes-example&repository=https://github.com/terraform-ibm-modules/terraform-ibm-schematics-agent/tree/main/examples/kubernetes"><img src="https://img.shields.io/badge/Deploy%20with IBM%20Cloud%20Schematics-0f62fe?logo=ibm&logoColor=white&labelColor=0f62fe" alt="Deploy with IBM Cloud Schematics" style="height: 16px; vertical-align: text-bottom;"></a>
<!-- END SCHEMATICS DEPLOY HOOK -->


An end-to-end example that provisions the following:
* A new resource group if one is not passed in.
* An Object Storage instance and a bucket.
* A basic VPC and subnet with public gateway enabled.
* An IBM VPC Gen2 Kubernetes cluster with 2 worker nodes and flavor "bx2.4x16".
* Creates and deploy the Schematics agent on the cluster.

<!-- BEGIN SCHEMATICS DEPLOY TIP HOOK -->
:information_source: Ctrl/Cmd+Click or right-click on the Schematics deploy button to open in a new tab
<!-- END SCHEMATICS DEPLOY TIP HOOK -->
