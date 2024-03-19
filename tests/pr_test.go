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
const region = "us-south"

// temporarily ignore destroy for schematics_agent_deploy as its currently in beta.
var ignoreDestroys = []string{
	"module.schematics_agent.ibm_schematics_agent.schematics_agent_instance",
	"module.schematics_agent.ibm_schematics_agent_deploy.schematics_agent_deploy",
}

func setupOptions(t *testing.T, prefix string, dir string) *testhelper.TestOptions {
	options := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
		Testing:       t,
		TerraformDir:  dir,
		Prefix:        prefix,
		ResourceGroup: resourceGroup,
		Region:        region,
		IgnoreDestroys: testhelper.Exemptions{
			List: ignoreDestroys,
		},
	})
	return options
}

func TestRunKubernetesExample(t *testing.T) {
	t.Parallel()

	options := setupOptions(t, "sa-k8s", kubernetesExampleDir)

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

func TestRunUpgradeExample(t *testing.T) {
	t.Parallel()

	options := setupOptions(t, "sa-k8s-upg", kubernetesExampleDir)

	output, err := options.RunTestUpgrade()
	if !options.UpgradeTestSkipped {
		assert.Nil(t, err, "This should not have errored")
		assert.NotNil(t, output, "Expected some output")
	}
}
