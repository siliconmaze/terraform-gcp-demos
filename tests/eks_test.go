// EKS Terratest - Production testing example
package tests

import (
	"fmt"
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestEksClusterWithNodeGroup(t *testing.T) {
	t.Parallel()

	// Unique ID for test resources
	uniqueID := random.UniqueId()
	project := fmt.Sprintf("terratest-%s", uniqueID)
	region := "us-east-1"

	// Terraform options
	terraformOptions := &terraform.Options{
		TerraformDir: "../modules/aws/eks",
		Vars: map[string]interface{}{
			"project":    project,
			"vpc_id":     aws.GetVpc(t, region).ID,
			"subnet_ids": aws.GetSubnetsForVpc(t, region),
		},
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": region,
		},
	}

	// Clean up resources
	defer terraform.Destroy(t, terraformOptions)

	// Apply Terraform
	terraform.InitAndApply(t, terraformOptions)

	// Verify cluster was created
	clusterName := terraform.Output(t, terraformOptions, "cluster_name")
	assert.NotEmpty(t, clusterName)

	// Verify node group exists
	nodeGroupName := terraform.Output(t, terraformOptions, "node_group_name")
	assert.NotEmpty(t, nodeGroupName)

	// Get cluster endpoint
	endpoint := terraform.Output(t, terraformOptions, "cluster_endpoint")
	assert.NotEmpty(t, endpoint)

	// Verify EKS cluster exists in AWS
	cluster := aws.GetEksCluster(t, region, clusterName)
	assert.Equal(t, clusterName, cluster.Name)
	assert.Equal(t, "ACTIVE", *cluster.Status)

	// Setup kubectl
	kubeconfigPath := k8s.NewKubectlOptions("", "")
	k8s.WriteKubeConfigFile(t, kubeconfigPath)

	// Verify nodes are ready
	nodes := k8s.GetNodes(t, kubeconfigPath, "default")
	assert.GreaterOrEqual(t, len(nodes), 1)
}

func TestEksClusterFargate(t *testing.T) {
	t.Parallel()

	uniqueID := random.UniqueId()
	project := fmt.Sprintf("terratest-fargate-%s", uniqueID)
	region := "us-east-1"

	terraformOptions := &terraform.Options{
		TerraformDir: "../modules/aws/eks",
		Vars: map[string]interface{}{
			"project":                  project,
			"vpc_id":                   aws.GetVpc(t, region).ID,
			"subnet_ids":              aws.GetSubnetsForVpc(t, region),
			"create_node_group":       false,
			"create_fargate_profile":  true,
			"fargate_namespace":        "fargate-test",
			"fargate_subnet_ids":      aws.GetSubnetsForVpc(t, region),
		},
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": region,
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Verify Fargate profile was created
	fargateArn := terraform.Output(t, terraformOptions, "fargate_profile_arn")
	require.NotEmpty(t, fargateArn)
}
