#!/bin/bash

#############################################################################
# This script is to check the deployment status of the Schematics Agent
#############################################################################

set -u

# Adding sleep for the token to be ready
sleep 10

MAX_ATTEMPTS=15
ATTEMPT=0

get_cloud_endpoint() {
    schematics_api_endpoint="${IBMCLOUD_SCHEMATICS_API_ENDPOINT:-"schematics.cloud.ibm.com"}"
    schematics_api_endpoint=${schematics_api_endpoint#https://}
    IBMCLOUD_SCHEMATICS_API_ENDPOINT=${schematics_api_endpoint%}
}

# Determine endpoints to use
get_cloud_endpoint

# Get IBM token to call API
# shellcheck disable=SC2154
IAM_TOKEN="$(echo "$IAM_ACCESS_TOKEN" | awk '{print $2}')"

# Verify Agent deployment status
status_code=""

echo "Checking status of the Schematics Agents..."

while ((ATTEMPT < MAX_ATTEMPTS)); do
    ATTEMPT=$((ATTEMPT + 1))

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
        echo "$result"
        exit 0
    elif [[ "$status_code" == "job_failed" ]]; then
        echo "ERROR: Agent $name deployment failed. Please go to the Schematics Agents dashboard(https://cloud.ibm.com/automation/schematics/extensions/agents) to check the logs."
        exit 1
    else
        sleep 30
        echo "Unknown status. Retrying in 30 secs..!!"
    fi
done

# Final check
if ((ATTEMPT >= MAX_ATTEMPTS)); then
    echo "ERROR: Reached maximum attempts. Please go to the Schematics Agents dashboard(https://cloud.ibm.com/automation/schematics/extensions/agents) to check the logs." >&2
    exit 1
fi
