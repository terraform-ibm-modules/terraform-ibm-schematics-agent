# Schematics Agent Policy

This submodule creates and configures the Schematics Agent Policy. More info on working with the agent policies can be found [here](https://cloud.ibm.com/docs/schematics?topic=schematics-policy-manage&interface=ui).

### Usage

```terraform
module schematics_policy {
  source              = "terraform-ibm-modules/schematics-agent/ibm//modules/schematics-policy"
  version             = "X.X.X" # replace X.X.X with a release version to lock into an exact release
  schematics_policies = {
    name           = "agent-policy"
    description    = "agent-description"
    location       = "us-south"
    resource_group = "<Resource Group of the Schematics Agent Policy>"
    tags           = ["terraform", "dev"]

    target = [{
      selector_kind = "ids"
      selector_ids  = "<Schematics Agent ID>"
    }]

    parameter = [{
      agent_assignment_policy_parameter = [{
        selector_kind = "scoped"

        selector_scope = [{
          kind            = "workspace"
          locations       = ["us-south"]
          resource_groups = ["<Resource Groups of the Schematics workspaces.>"]
        }]
      }]
    }]
  }
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

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.70.0, < 2.0.0 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [ibm_schematics_policy.policy](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/schematics_policy) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_schematics_policies"></a> [schematics\_policies](#input\_schematics\_policies) | Schematics agent policies to create | <pre>map(object({<br/>    name           = string<br/>    description    = optional(string)<br/>    location       = optional(string)<br/>    resource_group = optional(string)<br/>    tags           = optional(list(string), [])<br/><br/>    scoped_resources = optional(list(object({<br/>      id   = optional(string)<br/>      kind = optional(string)<br/>    })), [])<br/><br/>    target = optional(list(object({<br/>      selector_kind = optional(string)<br/>      selector_ids  = optional(list(string))<br/>      selector_scope = optional(list(object({<br/>        kind            = optional(string)<br/>        locations       = optional(list(string))<br/>        resource_groups = optional(list(string))<br/>        tags            = optional(list(string))<br/>      })), [])<br/>    })), [])<br/><br/>    parameter = optional(list(object({<br/>      agent_assignment_policy_parameter = optional(list(object({<br/>        selector_kind = optional(string)<br/>        selector_ids  = optional(list(string))<br/>        selector_scope = optional(list(object({<br/>          kind            = optional(string)<br/>          locations       = optional(list(string))<br/>          resource_groups = optional(list(string))<br/>          tags            = optional(list(string))<br/>        })), [])<br/>      })), [])<br/>    })), [])<br/>  }))</pre> | `{}` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_policies"></a> [policies](#output\_policies) | Schematics policy resources |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
