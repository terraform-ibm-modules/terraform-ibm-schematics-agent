// Tests in this file are run in the PR pipeline and the continuous testing pipeline
package test

import (
	"testing"

	"github.com/stretchr/testify/require"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/common"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testschematic"
)

// Use existing resource group
const resourceGroup = "geretain-test-resources"
const kubernetesExampleDir = "examples/kubernetes"
const openshiftExampleDir = "examples/openshift"

var validRegions = []string{
	"us-south",
	"eu-de",
	"eu-gb",
	"us-east",
	"ca-mon",
	"ca-tor",
}

func TestRunOpenShiftExampleInSchematics(t *testing.T) {
	t.Parallel()

	excludedRegion := "ca-mon"
	availableRegions := []string{}
	for _, r := range validRegions {
		if r != excludedRegion {
			availableRegions = append(availableRegions, r)
		}
	}
	region := availableRegions[common.CryptoIntn(len(availableRegions))]

	options := testschematic.TestSchematicOptionsDefault(&testschematic.TestSchematicOptions{
		Testing: t,
		Prefix:  "sa-ocp",
		/*
		 Comment out the 'ResourceGroup' input to force this tests to create a unique resource group to ensure tests do
		 not clash. This is due to the fact that the same resource group in the OpenShift Example is re-used for the
		 policy, workspace and the Schematics agent which might create conflict with other tests in the same RG which are
		 creating agent policies.
		*/
		//ResourceGroup:          resourceGroup,
		TemplateFolder:         openshiftExampleDir,
		WaitJobCompleteMinutes: 360,
		TarIncludePatterns: []string{"*.tf",
			openshiftExampleDir + "/*.tf",
			"scripts/*.sh",
			"scripts/*.py",
			"modules/schematics-policy/*.tf",
		},
	})

	options.TerraformVars = []testschematic.TestSchematicTerraformVar{
		{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
		{Name: "prefix", Value: options.Prefix, DataType: "string"},
		{Name: "region", Value: region, DataType: "string"},
	}

	require.NoError(t, options.RunSchematicTest(), "This should not have errored")
}

func TestRunKubernetesExampleInSchematics(t *testing.T) {
	t.Parallel()

	region := validRegions[common.CryptoIntn(len(validRegions))]

	options := testschematic.TestSchematicOptionsDefault(&testschematic.TestSchematicOptions{
		Testing:                t,
		Prefix:                 "sa-k8s",
		ResourceGroup:          resourceGroup,
		TemplateFolder:         kubernetesExampleDir,
		WaitJobCompleteMinutes: 360,
		TarIncludePatterns: []string{"*.tf",
			kubernetesExampleDir + "/*.tf",
			"scripts/*.sh",
			"scripts/*.py",
			"modules/schematics-policy/*.tf",
		},
	})

	options.TerraformVars = []testschematic.TestSchematicTerraformVar{
		{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
		{Name: "prefix", Value: options.Prefix, DataType: "string"},
		{Name: "region", Value: region, DataType: "string"},
	}

	require.NoError(t, options.RunSchematicTest(), "This should not have errored")
}

func TestRunOpenShiftUpgradeSchematics(t *testing.T) {
	t.Parallel()

	region := validRegions[common.CryptoIntn(len(validRegions))]

	options := testschematic.TestSchematicOptionsDefault(&testschematic.TestSchematicOptions{
		Testing: t,
		Prefix:  "sa-ocp-upg",
		/*
		 Comment out the 'ResourceGroup' input to force this tests to create a unique resource group to ensure tests do
		 not clash. This is due to the fact that the same resource group in the OpenShift Example is re-used for the
		 policy, workspace and the Schematics agent which might create conflict with other tests in the same RG which are
		 creating agent policies.
		*/
		//ResourceGroup:          resourceGroup,
		TemplateFolder:         openshiftExampleDir,
		WaitJobCompleteMinutes: 360,
		TarIncludePatterns: []string{"*.tf",
			openshiftExampleDir + "/*.tf",
			"scripts/*.sh",
			"scripts/*.py",
			"modules/schematics-policy/*.tf",
		},
	})

	options.TerraformVars = []testschematic.TestSchematicTerraformVar{
		{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
		{Name: "prefix", Value: options.Prefix, DataType: "string"},
		{Name: "region", Value: region, DataType: "string"},
	}

	require.NoError(t, options.RunSchematicUpgradeTest(), "This should not have errored")
}
