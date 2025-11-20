// Tests in this file are run in the PR pipeline and the continuous testing pipeline
package test

import (
	"math/rand"
	"testing"

	"github.com/stretchr/testify/require"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testschematic"
)

// Use existing resource group
const resourceGroup = "geretain-test-resources"
const completeExampleDir = "examples/complete"

var validRegions = []string{
	"us-south",
	"eu-de",
	"eu-gb",
	"us-east",
}

var validAgentLocation = []string{
	"us-south",
	"eu-de",
	"eu-gb",
	"us-east",
	"ca-mon",
	"eu-fr2",
	"ca-tor",
}

func TestRunCompleteExampleInSchematics(t *testing.T) {
	t.Parallel()

	region := validRegions[rand.Intn(len(validRegions))]
	agentLocation := validAgentLocation[rand.Intn(len(validAgentLocation))]

	options := testschematic.TestSchematicOptionsDefault(&testschematic.TestSchematicOptions{
		Testing:                t,
		Prefix:                 "sa-ocp",
		ResourceGroup:          resourceGroup,
		TemplateFolder:         completeExampleDir,
		WaitJobCompleteMinutes: 360,
		TarIncludePatterns: []string{"*.tf",
			completeExampleDir + "/*.tf",
			"scripts/*.sh",
		},
	})

	options.TerraformVars = []testschematic.TestSchematicTerraformVar{
		{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
		{Name: "prefix", Value: options.Prefix, DataType: "string"},
		{Name: "region", Value: region, DataType: "string"},
		{Name: "agent_location", Value: agentLocation, DataType: "string"},
	}

	require.NoError(t, options.RunSchematicTest(), "This should not have errored")
}

func TestRunUpgradeSchematics(t *testing.T) {
	t.Parallel()

	region := validRegions[rand.Intn(len(validRegions))]
	agentLocation := validAgentLocation[rand.Intn(len(validAgentLocation))]

	options := testschematic.TestSchematicOptionsDefault(&testschematic.TestSchematicOptions{
		Testing:                t,
		Prefix:                 "sa-k8s-upg",
		ResourceGroup:          resourceGroup,
		TemplateFolder:         completeExampleDir,
		WaitJobCompleteMinutes: 360,
		TarIncludePatterns: []string{"*.tf",
			completeExampleDir + "/*.tf",
			"scripts/*.sh",
		},
	})

	options.TerraformVars = []testschematic.TestSchematicTerraformVar{
		{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
		{Name: "prefix", Value: options.Prefix, DataType: "string"},
		{Name: "region", Value: region, DataType: "string"},
		{Name: "agent_location", Value: agentLocation, DataType: "string"},
		{Name: "kube_version", Value: "1.33.5", DataType: "string"},
		{Name: "infra_type", Value: "ibm_kubernetes", DataType: "string"},
	}

	require.NoError(t, options.RunSchematicUpgradeTest(), "This should not have errored")
}
