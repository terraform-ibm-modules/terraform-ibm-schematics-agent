#!/bin/bash

#############################################################################
# This script is to check the deployment status of the Schematics Agent
#############################################################################

name=$(ibmcloud schematics agent get --id "$AGENT_ID" -o json | jq -r .name)
status=$(ibmcloud schematics agent get --id "$AGENT_ID" -o json | jq -r .recent_deploy_job.status_code)
echo "status = $status"
if [[ "$status" == "job_finished" ]]; then
    echo "Agent $name deployed successfully."
elif [[ "$status" == "job_failed" ]]; then
    echo "ERROR: Agent $name deployment failed. Please go to the Schematics Agents dashboard(https://cloud.ibm.com/automation/schematics/extensions/agents) to check the logs."
    exit 1
fi
