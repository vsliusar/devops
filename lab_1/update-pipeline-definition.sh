#!/bin/bash

# Check if the pipeline definition JSON file is provided
if [ -z "$1" ]; then
    echo "Please provide the path to the pipeline definition JSON file."
    exit 1
fi


if [ "$1" = "--help" ]; then
    echo "Usage: $0 <json_file> [--configuration <value>] [--owner <value>] [--branch <value>] [--poll-for-source-changes <true|false>]"
    echo ""
    echo "Options:"
    echo "  --configuration <configuration_value>  Required: the build configuration value"
    echo "  --owner <owner_value>                  Required: the owner of the source code repository"
    echo "  --repo <repo_value>                    Required: the name of the source code repository"
    echo "  --branch <branch_value>                Optional: the name of the source code branch (default: main)"
    echo "  --poll-for-source-changes <true/false> Optional: whether to poll for source code changes (default: false)"
    echo "  --help                                 display help message"
    exit 1
fi

# Check if JQ is installed
if ! command -v jq &> /dev/null; then
    echo "JQ is not installed. Please install JQ before running this script. For example, on Ubuntu: sudo apt-get install jq"
    exit 1
fi


json_file=$1
shift
configuration_value=
owner_value=
branch_value=main
poll_for_source_changes_value=false

while [ $# -gt 0 ]; do
    case $1 in
        --configuration)
            configuration_value=$2
            shift
        ;;
        --owner)
            owner_value=$2
            shift
        ;;
        --branch)
            branch_value=$2
            shift
        ;;
        --poll-for-source-changes)
            poll_for_source_changes_value=$2
            shift
        ;;
        *)
            echo "Unknown parameter: $1"
            exit 1
        ;;
    esac
    shift
done

# Check if the JSON file exists
if [ ! -f "$json_file" ]; then
    echo "The JSON file does not exist."
    exit 1
fi

# Remove metadata
jq 'del(.metadata)' "$json_file" > "$json_file.tmp" && mv "$json_file.tmp" "$json_file"

# Increment pipeline version by 1
jq '.pipeline.version += 1' "$json_file" > "$json_file.tmp" && mv "$json_file.tmp" "$json_file"


#Check required values
if [ -z "$configuration_value" ]; then
    echo "The --configuration parameter is required."
    exit 1
fi

if [ -z "$owner_value" ]; then
    echo "The --owner parameter is required."
    exit 1
fi

if [ -z "$repo_value" ]; then
    echo "The --repo parameter is required."
    exit 1
fi

# Validate the JSON file
if ! jq -e .pipeline > /dev/null 2>&1 < "$json_file"; then
    echo "The JSON file is not valid."
    exit 1
fi

# Set Source action configuration values
jq --arg branch_value "$branch_value" '.pipeline.stages[0].actions[0].configuration.Branch = $branch_value' "$json_file" > "$json_file.tmp" && mv "$json_file.tmp" "$json_file"
jq --arg owner_value "$owner_value" '.pipeline.stages[0].actions[0].configuration.Owner = $owner_value' "$json_file" > "$json_file.tmp" && mv "$json_file.tmp" "$json_file"
jq --arg repo_value "$repo_value" '.pipeline.stages[0].actions[0].configuration.Repo = $repo_value' "$json_file" > "$json_file.tmp" && mv "$json_file.tmp" "$json_file"
jq --argjson poll_for_source_changes_value "$poll_for_source_changes_value" '.pipeline.stages[0].actions[0].configuration.PollForSourceChanges = $poll_for_source_changes_value' "$json_file" > "$json_file.tmp" && mv "$json_file.tmp" "$json_file"

# Set EnvironmentVariables properties in each action
jq --arg configuration_value "$configuration_value" '.pipeline.stages[].actions[].configuration.EnvironmentVariables = "[{\"name\":\"BUILD_CONFIGURATION\",\"value\":\"" + $configuration_value + "\",\"type\":\"PLAINTEXT\"}]"' "$json_file" > "$json_file.tmp" && mv "$json_file.tmp" "$json_file"

# Output the modified JSON file
timestamp=$(date +%Y%m%d%H%M%S)
new_json_file="pipeline-$timestamp.json"
cp "$json_file" "$new_json_file"
echo "The modified JSON file has been saved as $new_json_file"