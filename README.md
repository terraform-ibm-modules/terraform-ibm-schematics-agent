<!-- Update the title -->
# Terraform Schematics Agent Module

<!--
Update status and "latest release" badges:
  1. For the status options, see https://terraform-ibm-modules.github.io/documentation/#/badge-status
  2. Update the "latest release" badge to point to the correct module's repo. Replace "terraform-ibm-module-template" in two places.
-->
[![Stable (With quality checks)](https://img.shields.io/badge/Status-Stable%20(With%20quality%20checks)-green)](https://terraform-ibm-modules.github.io/documentation/#/badge-status)
[![latest release](https://img.shields.io/github/v/release/terraform-ibm-modules/terraform-ibm-schematics-agent?logo=GitHub&sort=semver)](https://github.com/terraform-ibm-modules/terraform-ibm-schematics-agent/releases/latest)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![Renovate enabled](https://img.shields.io/badge/renovate-enabled-brightgreen.svg)](https://renovatebot.com/)
[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)

<!-- Add a description of module(s) in this repo -->
Installs and deploy an IBM Schematics Agent on the cluster. To deploy an schematics agent, you should have admin access of the cluster.

Refer [here](https://cloud.ibm.com/docs/schematics?topic=schematics-deploy-agent-overview&interface=ui) for more information about the IBM Schematics Agent.


<!-- Below content is automatically populated via pre-commit hook -->
<!-- BEGIN OVERVIEW HOOK -->
## Overview
* [terraform-ibm-schematics-agent](#terraform-ibm-schematics-agent)
* [Examples](./examples)
    * [Kubernetes example](./examples/kubernetes)
    * [OpenShift example](./examples/openshift)
* [Contributing](#contributing)
<!-- END OVERVIEW HOOK -->


<!--
If this repo contains any reference architectures, uncomment the heading below and links to them.
(Usually in the `/reference-architectures` directory.)
See "Reference architecture" in Authoring Guidelines in the public documentation at
https://terraform-ibm-modules.github.io/documentation/#/implementation-guidelines?id=reference-architecture
-->
<!-- ## Reference architectures -->


<!-- This heading should always match the name of the root level module (aka the repo name) -->
## terraform-ibm-schematics-agent

### Usage

<!--
Add an example of the use of the module in the following code block.

Use real values instead of "var.<var_name>" or other placeholder values
unless real values don't help users know what to change.
-->

```hcl

provider "ibm" {
  ibmcloud_api_key = "XXXXXXXXXX"
  region           = "us-south"
}

module "schematics_agent" {
  source                      = "terraform-ibm-modules/schematics-agent/ibm"
  version                     = "latest" # Replace "latest" with a release version to lock into a specific release
  infra_type                  = "ibm_openshift"
  cluster_id                  = "<cluster-id>"
  cluster_resource_group_name = "Default"
  cos_instance_name           = "<cos-instance-name>"
  cos_bucket_name             = "<cos-bucket-name>"
  cos_bucket_region           = "<cos-bucket-region>"
  agent_location              = "us-south"
  agent_description           = "schematics agent description"
  agent_name                  = "k8s-schematics-agent"
  agent_resource_group_name   = "Default"
  schematics_location         = "us-south" # Allowed values are `us-south`, `us-east`, `eu-gb`, `eu-de`.
  agent_version               = "1.5.0"
  agent_tags                  = []
}

```

### Required IAM access policies

<!-- PERMISSIONS REQUIRED TO RUN MODULE
If this module requires permissions, uncomment the following block and update
the sample permissions, following the format.
Replace the sample Account and IBM Cloud service names and roles with the
information in the console at
Manage > Access (IAM) > Access groups > Access policies.
-->

You need the following permissions to run this module.

- Account Management
    - **Resource group**
        - `Viewer` access
    - IAM Services
        - **Schematics** service
            - `Writer` service access
            - `Manager` service access
        - **Kubernetes** Service
            - `Administrator` platform access
            - `Manager` service access


<!-- NO PERMISSIONS FOR MODULE
If no permissions are required for the module, uncomment the following
statement instead the previous block.
-->

<!-- No permissions are needed to run this module.-->

<!-- Below content is automatically populated via pre-commit hook -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.70.0, < 2.0.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 3.2.1, < 4.0.0 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [ibm_schematics_agent.schematics_agent_instance](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/schematics_agent) | resource |
| [ibm_schematics_agent_deploy.schematics_agent_deploy](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/schematics_agent_deploy) | resource |
| [null_resource.agent_deployment_status](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [ibm_iam_auth_token.tokendata](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/iam_auth_token) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_agent_description"></a> [agent\_description](#input\_agent\_description) | The schematics agent description. | `string` | `null` | no |
| <a name="input_agent_location"></a> [agent\_location](#input\_agent\_location) | The location where the schematics agent is deployed in the user environment. | `string` | `"us-south"` | no |
| <a name="input_agent_metadata"></a> [agent\_metadata](#input\_agent\_metadata) | The metadata of the agent. | <pre>object({<br/>    name  = optional(string)<br/>    value = optional(list(string))<br/>  })</pre> | `{}` | no |
| <a name="input_agent_name"></a> [agent\_name](#input\_agent\_name) | The schematics agent name. | `string` | n/a | yes |
| <a name="input_agent_resource_group_name"></a> [agent\_resource\_group\_name](#input\_agent\_resource\_group\_name) | The resource group name for the schematics agent. | `string` | n/a | yes |
| <a name="input_agent_tags"></a> [agent\_tags](#input\_agent\_tags) | The list of tags to be added to the agent. | `list(string)` | `[]` | no |
| <a name="input_agent_version"></a> [agent\_version](#input\_agent\_version) | The schematics agent version. More info: https://cloud.ibm.com/docs/schematics?topic=schematics-update-agent-overview&interface=ui#agent_version-releases | `string` | `"1.5.0"` | no |
| <a name="input_cluster_id"></a> [cluster\_id](#input\_cluster\_id) | ID of the target cluster where the schematics agent will be installed. | `string` | n/a | yes |
| <a name="input_cluster_resource_group_name"></a> [cluster\_resource\_group\_name](#input\_cluster\_resource\_group\_name) | The resource group name of the target cluster where the schematics agent will be installed. | `string` | n/a | yes |
| <a name="input_cos_bucket_name"></a> [cos\_bucket\_name](#input\_cos\_bucket\_name) | The Object Storage bucket name to store the schematics agent logs. | `string` | n/a | yes |
| <a name="input_cos_bucket_region"></a> [cos\_bucket\_region](#input\_cos\_bucket\_region) | The Object Storage bucket region. | `string` | n/a | yes |
| <a name="input_cos_instance_name"></a> [cos\_instance\_name](#input\_cos\_instance\_name) | The Object Storage instance name where the bucket is created for the schematics agent logs. | `string` | n/a | yes |
| <a name="input_disable_agent"></a> [disable\_agent](#input\_disable\_agent) | User defined status of the agent. Set to `true` to disable the agent. By default the agent state will be enabled. | `bool` | `false` | no |
| <a name="input_infra_type"></a> [infra\_type](#input\_infra\_type) | Type of target agent infrastructure. Allowed values: `ibm_kubernetes`, `ibm_openshift` and `ibm_satellite`. | `string` | `"ibm_kubernetes"` | no |
| <a name="input_run_destroy_resources_job"></a> [run\_destroy\_resources\_job](#input\_run\_destroy\_resources\_job) | Set this value to `false` if you do not want to destroy resources associated with the agent deployment. Defaults to `true`. | `bool` | `true` | no |
| <a name="input_schematics_location"></a> [schematics\_location](#input\_schematics\_location) | The location to create the Schematics workspace. Allowed values are `us-south`, `us-east`, `eu-gb`, `eu-de`. | `string` | `"us-south"` | no |
| <a name="input_use_schematics_private_endpoint"></a> [use\_schematics\_private\_endpoint](#input\_use\_schematics\_private\_endpoint) | Set to `true` if you want to access Schematics via private endpoint. | `bool` | `false` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_agent_crn"></a> [agent\_crn](#output\_agent\_crn) | Schematics agent CRN. |
| <a name="output_agent_id"></a> [agent\_id](#output\_agent\_id) | Schematics agent ID. |
| <a name="output_log_url"></a> [log\_url](#output\_log\_url) | URL to the full schematics agent deployment job logs. |
| <a name="output_status_code"></a> [status\_code](#output\_status\_code) | Final result of the schematics agent deployment job. |
| <a name="output_status_message"></a> [status\_message](#output\_status\_message) | The outcome of the schematics agent deployment job, in a formatted log string. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

<!-- Leave this section as is so that your module has a link to local development environment set up steps for contributors to follow -->
## Contributing

You can report issues and request features for this module in GitHub issues in the module repo. See [Report an issue or request a feature](https://github.com/terraform-ibm-modules/.github/blob/main/.github/SUPPORT.md).

To set up your local development environment, see [Local development setup](https://terraform-ibm-modules.github.io/documentation/#/local-dev-setup) in the project documentation.
