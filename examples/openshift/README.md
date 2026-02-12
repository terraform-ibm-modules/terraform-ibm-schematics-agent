# OpenShift example

<!-- BEGIN SCHEMATICS DEPLOY HOOK -->
<a href="https://cloud.ibm.com/schematics/workspaces/create?workspace_name=schematics-agent-openshift-example&repository=https://github.com/terraform-ibm-modules/terraform-ibm-schematics-agent/tree/main/examples/openshift"><img src="https://img.shields.io/badge/Deploy%20with IBM%20Cloud%20Schematics-0f62fe?logo=ibm&logoColor=white&labelColor=0f62fe" alt="Deploy with IBM Cloud Schematics" style="height: 16px; vertical-align: text-bottom;"></a>
<!-- END SCHEMATICS DEPLOY HOOK -->


An end-to-end example that provisions the following:
* A new resource group if one is not passed in.
* An Object Storage instance and a bucket.
* A basic VPC and subnet with public gateway enabled (unless `private_only_cluster` is set to `true`).
* An IBM VPC Gen2 OpenShift cluster with 2 worker nodes and flavor "bx2.4x16".
* Creates and deploy the Schematics agent on the cluster.
* Creates the Schematics agent policy for the agent and bind it with the Schematics workspace.

## Private Cluster Deployment

This example supports deploying to a private-only OpenShift cluster by setting `private_only_cluster = true`.

When enabled:
- No public gateway is created
- Outbound traffic protection is enabled on the cluster (blocks public internet access)

**Important Notes:**
- Public internet access is **NOT required** to install or run the Schematics agent
- IBM Cloud services (Schematics, Cloud Object Storage) remain accessible via private service endpoints
- If your Terraform configurations pull modules or providers from the public internet, you must either:
  - Configure a [private registry](https://cloud.ibm.com/docs/schematics?topic=schematics-agent-registry-overview) for Terraform providers
  - Set up a proxy to allow controlled outbound access

<!-- BEGIN SCHEMATICS DEPLOY TIP HOOK -->
:information_source: Ctrl/Cmd+Click or right-click on the Schematics deploy button to open in a new tab
<!-- END SCHEMATICS DEPLOY TIP HOOK -->
