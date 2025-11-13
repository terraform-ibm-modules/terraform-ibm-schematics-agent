// Tests in this file are run in the PR pipeline and the continuous testing pipeline
package test

import (
	"testing"

	"github.com/stretchr/testify/assert"

	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
)

// Use existing resource group
const resourceGroup = "geretain-test-resources"
const kubernetesExampleDir = "examples/kubernetes"

// temporarily ignore destroy for schematics_agent_deploy as its currently in beta. https://github.com/IBM-Cloud/terraform-provider-ibm/issues/5475 - fixed in 1.70.0

// var ignoreDestroys = []string{
// 	"module.schematics_agent.ibm_schematics_agent.schematics_agent_instance",
// 	"module.schematics_agent.ibm_schematics_agent_deploy.schematics_agent_deploy",
// }

func setupOptions(t *testing.T, prefix string, dir string) *testhelper.TestOptions {
	// region := validRegions[rand.Intn(len(validRegions))]
	// agentLocation := validAgentLocation[rand.Intn(len(validAgentLocation))]

	const region = "us-south"
	options := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
		Testing:       t,
		TerraformDir:  dir,
		Prefix:        prefix,
		ResourceGroup: resourceGroup,
		Region:        region,
	})
	return options
}

func TestRunKubernetesExample1(t *testing.T) {
	t.Parallel()

	options := setupOptions(t, "agent", kubernetesExampleDir)

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")

	outputs := options.LastTestTerraformOutputs
	expectedOutputs := []string{"schematics_agent_status_code"}
	_, outputErr := testhelper.ValidateTerraformOutputs(outputs, expectedOutputs...)
	if assert.NoErrorf(t, outputErr, "Some outputs not found or nil.") {
		assert.Equal(t, outputs["schematics_agent_status_code"].(string), "job_finished")
	}
}

// var validRegions = []string{
// 	"us-south",
// 	"eu-de",
// 	"eu-gb",
// 	"us-east",
// }

// var validAgentLocation = []string{
// 	"us-south",
// 	"eu-de",
// 	"eu-gb",
// 	"us-east",
// 	"ca-mon",
// 	"eu-fr2",
// 	"ca-tor",
// }

// func TestRunKubernetesExampleInSchematics(t *testing.T) {
// 	t.Parallel()

// 	region := validRegions[rand.Intn(len(validRegions))]
// 	agentLocation := validAgentLocation[rand.Intn(len(validAgentLocation))]

// 	options := testschematic.TestSchematicOptionsDefault(&testschematic.TestSchematicOptions{
// 		Testing:                t,
// 		Prefix:                 "sa-k8s",
// 		ResourceGroup:          resourceGroup,
// 		TemplateFolder:         kubernetesExampleDir,
// 		WaitJobCompleteMinutes: 360,
// 		TarIncludePatterns: []string{"*.tf",
// 			kubernetesExampleDir + "/*.tf",
// 		},
// 	})

// 	options.SkipTestTearDown = true
// 	options.TerraformVars = []testschematic.TestSchematicTerraformVar{
// 		{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
// 		{Name: "prefix", Value: options.Prefix, DataType: "string"},
// 		{Name: "region", Value: region, DataType: "string"},
// 		{Name: "agent_location", Value: agentLocation, DataType: "string"},
// 	}

// 	require.NoError(t, options.RunSchematicTest(), "This should not have errored")
// }

// func TestRunUpgradeSchematics(t *testing.T) {
// 	t.Parallel()

// 	region := validRegions[rand.Intn(len(validRegions))]
// 	agentLocation := validAgentLocation[rand.Intn(len(validAgentLocation))]

// 	options := testschematic.TestSchematicOptionsDefault(&testschematic.TestSchematicOptions{
// 		Testing:                t,
// 		Prefix:                 "sa-k8s-upg",
// 		ResourceGroup:          resourceGroup,
// 		TemplateFolder:         kubernetesExampleDir,
// 		WaitJobCompleteMinutes: 360,
// 		TarIncludePatterns: []string{"*.tf",
// 			kubernetesExampleDir + "/*.tf",
// 		},
// 	})

// 	options.TerraformVars = []testschematic.TestSchematicTerraformVar{
// 		{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
// 		{Name: "prefix", Value: options.Prefix, DataType: "string"},
// 		{Name: "region", Value: region, DataType: "string"},
// 		{Name: "agent_location", Value: agentLocation, DataType: "string"},
// 	}

// 	require.NoError(t, options.RunSchematicUpgradeTest(), "This should not have errored")
// }
