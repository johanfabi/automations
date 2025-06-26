#!/bin/bash

# This script creates snapshots of all persistent disks attached to a specified GCE instance.
#
# Usage: ./snapshot_gce_disks.sh <INSTANCE_NAME> <ZONE> <PROJECT_ID>
#
# Arguments:
#   <INSTANCE_NAME> : The name of your Google Compute Engine instance.
#   <ZONE>          : The zone where your GCE instance is located (e.g., us-central1-a).
#   <PROJECT_ID>    : Your Google Cloud Project ID.
#
# Example: ./snapshot_gce_disks.sh my-web-server us-central1-a my-gcp-project-123

# Check if the correct number of arguments is provided
if [ "$#" -ne 3 ]; then
  echo "Error: Incorrect number of arguments."
  echo "Usage: $0 <INSTANCE_NAME> <ZONE> <PROJECT_ID>"
  echo "Example: $0 my-web-server us-central1-a my-gcp-project-123"
  exit 1
fi

# Assign command line arguments to variables
INSTANCE_NAME="$1"
ZONE="$2"
PROJECT_ID="$3" # New variable for the project ID

echo "Attempting to create snapshots for instance: $INSTANCE_NAME in zone: $ZONE in project: $PROJECT_ID"

# Get a list of disk names attached to the instance.
# We use 'jq' to parse the JSON output from 'gcloud compute instances describe'
# and extract the actual disk 'name' from the 'source' URL for all 'PERSISTENT' type disks.
# The 'source' field contains the full resource URL of the disk, from which we can extract the name.
# Added --project flag to specify the GCP project.
DISK_NAMES=$(gcloud compute instances describe "$INSTANCE_NAME" \
  --zone="$ZONE" \
  --project="$PROJECT_ID" \
  --format="json" | jq -r '.disks[] | select(.type == "PERSISTENT") | .source | split("/") | last')

# Check if any disks were found for the specified instance and zone
if [ -z "$DISK_NAMES" ]; then
  echo "No persistent disks found for instance '$INSTANCE_NAME' in zone '$ZONE' in project '$PROJECT_ID'."
  echo "Please ensure the instance name, zone, and project ID are correct and the instance exists."
  exit 1
fi

echo "Found the following persistent disks for instance '$INSTANCE_NAME':"
# Display the list of disks found for user confirmation
echo "$DISK_NAMES" # Disks are already separated by newlines by jq -r

# Loop through each disk name and create a snapshot
for DISK_NAME in $DISK_NAMES; do
  # Construct a unique snapshot name using the instance name, disk name, and a timestamp
  # Format: <instance-name>-<disk-name>-snapshot-YYYYMMDDHHMM
  SNAPSHOT_NAME="${INSTANCE_NAME}-${DISK_NAME}-snapshot-$(date +%Y%m%d%H%M)"

  echo "Creating snapshot '$SNAPSHOT_NAME' from disk '$DISK_NAME' in zone '$ZONE' in project '$PROJECT_ID'..."

  # Execute the gcloud command to create the snapshot
  # This command takes the snapshot name as a positional argument and uses --source-disk to specify the disk.
  # Added --project flag to specify the GCP project.
  # '--async' flag runs the operation in the background so the script doesn't wait
  gcloud compute snapshots create "$SNAPSHOT_NAME" \
    --source-disk="$DISK_NAME" \
    --source-disk-zone="$ZONE" \
    --project="$PROJECT_ID" \
    --description="Snapshot of disk $DISK_NAME from instance $INSTANCE_NAME" \
    --async
done

echo "Snapshot creation commands initiated for all relevant disks on '$INSTANCE_NAME' in project '$PROJECT_ID'."
echo "You can monitor the progress and status of your new snapshots in the Google Cloud Console"
echo "under 'Compute Engine' -> 'Snapshots'."