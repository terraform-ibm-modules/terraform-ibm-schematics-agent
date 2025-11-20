#!/bin/bash

#############################################################################
# This script is to check the deployment status of the Schematics Agent
#############################################################################

set -eo pipefail

REGION="${1:-}"
AGENT_ID="${2:-}"
PRIVATE_ENV="${3:-false}"

if [[ -z "${REGION}" ]]; then
    echo "Region must be passed as first input script argument" >&2
    exit 1
fi

if [[ -z "${AGENT_ID}" ]]; then
    echo "Agent ID must be passed as second input script argument" >&2
    exit 1
fi

if [[ -z "${IBMCLOUD_API_KEY}" ]]; then
    echo "IBM Cloud api key must be set using the environment variable IBMCLOUD_API_KEY" >&2
    exit 1
fi
set -u

get_cloud_endpoint() {
    iam_cloud_endpoint="${IBMCLOUD_IAM_API_ENDPOINT:-"iam.cloud.ibm.com"}"
    IBMCLOUD_IAM_API_ENDPOINT=${iam_cloud_endpoint#https://}

    schematics_api_endpoint="${IBMCLOUD_SCHEMATICS_API_ENDPOINT:-"schematics.cloud.ibm.com"}"
    schematics_api_endpoint=${schematics_api_endpoint#https://}
    IBMCLOUD_SCHEMATICS_API_ENDPOINT=${schematics_api_endpoint%}
}

# Determine endpoints to use
get_cloud_endpoint

# Generate IAM access token
IAM_RESPONSE=$(curl -s --request POST \
"https://${IBMCLOUD_IAM_API_ENDPOINT}/identity/token" \
--header 'Content-Type: application/x-www-form-urlencoded' \
--header 'Accept: application/json' \
--data-urlencode 'grant_type=urn:ibm:params:oauth:grant-type:apikey' --data-urlencode 'apikey='"${IBMCLOUD_API_KEY}") #pragma: allowlist secret

ERROR_MESSAGE=$(echo "${IAM_RESPONSE}" | jq 'has("errorMessage")')
if [[ "${ERROR_MESSAGE}" != false ]]; then
    echo "${IAM_RESPONSE}" | jq '.errorMessage'
    echo "Could not obtain an access token"
    exit 1
fi

IAM_TOKEN=$(echo "${IAM_RESPONSE}" | jq -r '.access_token')

# Verify Agent deployment status
status_code=""

if [ "$IBMCLOUD_SCHEMATICS_API_ENDPOINT" = "schematics.cloud.ibm.com" ]; then
    if [ "$PRIVATE_ENV" = true ]; then
        GET_AGENT_URL="https://private-$REGION.$IBMCLOUD_SCHEMATICS_API_ENDPOINT/v2/agents/$AGENT_ID?profile=detailed"
        result=$(curl -s -H "accept: application/json" -H "Authorization: Bearer $IAM_TOKEN" "$GET_AGENT_URL" 2>/dev/null)
        status_code=$(echo "$result" | jq -r .recent_deploy_job.status_code)
        name=$(echo "$result" | jq -r .name)
    else
        GET_AGENT_URL="https://$REGION.$IBMCLOUD_SCHEMATICS_API_ENDPOINT/v2/agents/$AGENT_ID?profile=detailed"
        result=$(curl -s -H "accept: application/json" -H "Authorization: Bearer $IAM_TOKEN" "$GET_AGENT_URL" 2>/dev/null)
        status_code=$(echo "$result" | jq -r .recent_deploy_job.status_code)
        name=$(echo "$result" | jq -r .name)
    fi
else
    GET_AGENT_URL="https://$REGION.$IBMCLOUD_SCHEMATICS_API_ENDPOINT/v2/agents/$AGENT_ID?profile=detailed"
    result=$(curl -s -H "accept: application/json" -H "Authorization: Bearer $IAM_TOKEN" "$GET_AGENT_URL" 2>/dev/null)
    status_code=$(echo "$result" | jq -r .recent_deploy_job.status_code)
    name=$(echo "$result" | jq -r .name)
fi

if [[ "$status_code" == "job_finished" ]]; then
    echo "Agent $name deployed successfully."
    exit 0
elif [[ "$status_code" == "job_failed" ]]; then
    echo "ERROR: Agent $name deployment failed. Please go to the Schematics Agents dashboard(https://cloud.ibm.com/automation/schematics/extensions/agents) to check the logs."
    exit 1
else
    echo "ERROR: Unknown status. Please go to the Schematics Agents dashboard(https://cloud.ibm.com/automation/schematics/extensions/agents) to check the logs."
    exit 1
fi
