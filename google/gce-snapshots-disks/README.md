# gce-snapshots-disks

This Bash script automates the creation of snapshots for all persistent disks attached to a specific Google Compute Engine (GCE) instance.

## Usage

```sh
./gce-snapshots-disks.sh <INSTANCE_NAME> <ZONE> <PROJECT_ID>
```

- `<INSTANCE_NAME>`: The name of your GCE instance.
- `<ZONE>`: The zone where your GCE instance is located (e.g., `us-central1-a`).
- `<PROJECT_ID>`: Your Google Cloud Project ID.

**Example:**

```sh
./gce-snapshots-disks.sh my-web-server us-central1-a my-gcp-project-123
```

## Requirements

- [Google Cloud SDK (`gcloud`)](https://cloud.google.com/sdk/docs/install) installed and authenticated.
- [`jq`](https://stedolan.github.io/jq/download/) installed for JSON processing.
- Sufficient permissions to list instances and create snapshots in the specified GCP project.

## What does the script do?

1. Retrieves all persistent disks attached to the specified instance.
2. Creates a snapshot for each disk, naming it with the format:  
   `<instance-name>-<disk-name>-snapshot-YYYYMMDDHHMM`
3. Runs snapshot creation asynchronously.

## Notes

- You can monitor snapshot progress in the Google Cloud Console under "Compute Engine" → "Snapshots".
- If no persistent disks are found, the script will display an error message.

## License

This project is licensed under the Apache 2.0 License. See the [LICENSE](../../LICENSE) file for