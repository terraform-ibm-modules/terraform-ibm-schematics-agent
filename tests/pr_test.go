// Tests in this file are run in the PR pipeline and the continuous testing pipeline
package test

import (
	"bytes"
	"fmt"
	"log"
	"os"
	"os/exec"
	"testing"

	"github.com/google/uuid"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/cloudinfo"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/common"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testschematic"
)

// Use existing resource group
const resourceGroup = "geretain-test-resources"
const kubernetesExampleDir = "examples/kubernetes"
const openshiftExampleDir = "examples/openshift"

var sharedInfoSvc *cloudinfo.CloudInfoService

var validRegions = []string{
	"us-south",
	"eu-de",
	"eu-gb",
	"us-east",
	"ca-tor",
}

// TestMain will be run before any parallel tests, used to read data from yaml for use with tests
func TestMain(m *testing.M) {
	var err error
	sharedInfoSvc, err = cloudinfo.NewCloudInfoServiceFromEnv("TF_VAR_ibmcloud_api_key", cloudinfo.CloudInfoServiceOptions{})
	if err != nil {
		log.Fatal(err)
	}

	os.Exit(m.Run())
}

func generateUniqueResourceGroupName(baseName string) string {
	id := uuid.New().String()[:8]
	return fmt.Sprintf("%s-%s", baseName, id)
}

func validateEnvVariable(t *testing.T, varName string) string {
	val, present := os.LookupEnv(varName)
	require.True(t, present, "%s environment variable not set", varName)
	require.NotEqual(t, "", val, "%s environment variable is empty", varName)
	return val
}

func createContainersApikey(t *testing.T, region string, rg string) {

	err := os.Setenv("IBMCLOUD_API_KEY", validateEnvVariable(t, "TF_VAR_ibmcloud_api_key"))
	require.NoError(t, err, "Failed to set IBMCLOUD_API_KEY environment variable")
	scriptPath := "../common-dev-assets/scripts/iks-api-key-reset/reset_iks_api_key.sh"
	cmd := exec.Command("bash", scriptPath, region, rg)
	var stdout, stderr bytes.Buffer
	cmd.Stdout = &stdout
	cmd.Stderr = &stderr

	// Execute the command
	if err := cmd.Run(); err != nil {
		log.Fatalf("Failed to execute script: %v\nStderr: %s", err, stderr.String())
	}
	// Print script output
	fmt.Println(stdout.String())
}

func TestRunOpenShiftExampleInSchematics(t *testing.T) {
	t.Parallel()

	region := validRegions[common.CryptoIntn(len(validRegions))]

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

	uniqueResourceGroup := generateUniqueResourceGroupName(options.Prefix)

	options.TerraformVars = []testschematic.TestSchematicTerraformVar{
		{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
		{Name: "prefix", Value: options.Prefix, DataType: "string"},
		{Name: "region", Value: region, DataType: "string"},
		{Name: "resource_group", Value: uniqueResourceGroup, DataType: "string"},
	}

	err := sharedInfoSvc.WithNewResourceGroup(uniqueResourceGroup, func() error {
		// Temp workaround for https://github.com/terraform-ibm-modules/terraform-ibm-base-ocp-vpc?tab=readme-ov-file#the-specified-api-key-could-not-be-found
		createContainersApikey(t, options.Region, uniqueResourceGroup)
		return options.RunSchematicTest()
	})
	assert.Nil(t, err, "This should not have errored")
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

	// Temp workaround for https://github.com/terraform-ibm-modules/terraform-ibm-base-ocp-vpc?tab=readme-ov-file#the-specified-api-key-could-not-be-found
	createContainersApikey(t, options.Region, options.ResourceGroup)

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

	uniqueResourceGroup := generateUniqueResourceGroupName(options.Prefix)

	options.TerraformVars = []testschematic.TestSchematicTerraformVar{
		{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
		{Name: "prefix", Value: options.Prefix, DataType: "string"},
		{Name: "region", Value: region, DataType: "string"},
		{Name: "resource_group", Value: uniqueResourceGroup, DataType: "string"},
	}

	err := sharedInfoSvc.WithNewResourceGroup(uniqueResourceGroup, func() error {
		// Temp workaround for https://github.com/terraform-ibm-modules/terraform-ibm-base-ocp-vpc?tab=readme-ov-file#the-specified-api-key-could-not-be-found
		createContainersApikey(t, options.Region, uniqueResourceGroup)
		return options.RunSchematicUpgradeTest()
	})
	assert.Nil(t, err, "This should not have errored")
}
