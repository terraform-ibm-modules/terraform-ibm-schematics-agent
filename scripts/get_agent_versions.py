#!/usr/bin/env python3
import http.client
import json
import os
import re
import sys
from urllib.parse import urlparse


def parse_input():
    """
    Reads JSON input from stdin and parses it into a dictionary.
    Returns:
        dict: Parsed input data.
    """
    try:
        data = json.loads(sys.stdin.read())
    except json.JSONDecodeError as e:
        raise ValueError("Invalid JSON input") from e
    return data


def validate_inputs(data):
    """
    Validates required inputs 'IAM_TOKEN' and 'REGION' from the parsed input.
    Args:
        data (dict): Input data parsed from JSON.
    Returns:
        tuple: A tuple containing (IAM_TOKEN, REGION, PRIVATE_ENV).
    """
    token = data.get("IAM_TOKEN")
    if not token:
        raise ValueError("IAM_TOKEN is required")

    region = data.get("REGION")
    if not region:
        raise ValueError("REGION is required")

    private_env = data.get("PRIVATE_ENV", "false").lower() == "true"

    return token, region, private_env


def get_api_endpoint(region, private_env):
    """
    Retrieves the API endpoint, checking for environment variable override.
    Args:
        region (str): IBM Cloud region.
        private_env (bool): Whether to use private endpoint.
    Returns:
        str: The API endpoint URL.
    """
    api_endpoint = os.getenv("IBMCLOUD_SCHEMATICS_API_ENDPOINT")
    if not api_endpoint:
        prefix = "private-" if private_env else ""
        api_endpoint = f"https://{prefix}{region}.schematics.cloud.ibm.com"
    return api_endpoint


def fetch_agent_versions(iam_token, api_endpoint):
    """
    Fetches Schematics agent versions using HTTP connection.
    Args:
        iam_token (str): IBM Cloud IAM token for authentication.
        api_endpoint (str): Base API endpoint URL.
    Returns:
        dict: Parsed JSON response containing agent version information.
    """
    # Add https if user passed just a hostname
    if not api_endpoint.startswith("https://"):
        api_endpoint = f"https://{api_endpoint}"

    parsed = urlparse(api_endpoint)
    host = parsed.hostname

    if iam_token.startswith("Bearer "):
        auth_header = iam_token
    else:
        auth_header = f"Bearer {iam_token}"
    headers = {
        "Authorization": auth_header,
        "Accept": "application/json",
    }

    conn = http.client.HTTPSConnection(host)
    try:
        conn.request("GET", "/v2/agents/versions", headers=headers)
        response = conn.getresponse()
        data = response.read().decode()

        if response.status != 200:
            raise RuntimeError(
                f"API request failed: {response.status} {response.reason} - {data}"
            )

        return json.loads(data)
    except http.client.HTTPException as e:
        raise RuntimeError("HTTP request failed") from e
    finally:
        conn.close()


def semver_key(version):
    """
    Sort key for semantic versioning.
    Args:
        version (str): Version string in semver format (e.g., "1.5.0").
    Returns:
        tuple: Tuple of integers for sorting.
    """
    match = re.match(r"(\d+)\.(\d+)\.(\d+)", version)
    if match:
        return tuple(int(x) for x in match.groups())
    return (0, 0, 0)


def transform_agent_versions(versions_data):
    """
    Transforms agent versions data into a sorted list.
    Args:
        versions_data (dict): Raw data returned by the agent versions API.
    Returns:
        list: Sorted list of version strings (newest first).
    """
    versions = []
    for v in versions_data.get("supported_agent_versions", []):
        display_name = v.get("display_name")
        if display_name:
            # Strip 'v' prefix if present (API returns v1.5.0, we want 1.5.0)
            if display_name.startswith("v"):
                display_name = display_name[1:]
            versions.append(display_name)

    if not versions:
        raise RuntimeError("No agent versions found.")

    # Sort descending (newest first)
    versions.sort(key=semver_key, reverse=True)

    return versions


def format_for_terraform(versions):
    """
    Converts the version list into JSON string for Terraform external data source consumption.
    Args:
        versions (list): List of version strings.
    Returns:
        dict: A dictionary with versions as JSON string.
    """
    return {"versions": json.dumps(versions)}


def main():
    """
    Main execution function: reads input, validates, fetches API data, transforms it,
    formats it for Terraform and prints the JSON output.
    """
    data = parse_input()
    iam_token, region, private_env = validate_inputs(data)
    api_endpoint = get_api_endpoint(region, private_env)
    versions_data = fetch_agent_versions(iam_token, api_endpoint)
    versions = transform_agent_versions(versions_data)
    output = format_for_terraform(versions)

    print(json.dumps(output))


if __name__ == "__main__":
    main()
