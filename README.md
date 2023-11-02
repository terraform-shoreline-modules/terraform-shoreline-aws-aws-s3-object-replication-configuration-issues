
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# Issues with Amazon S3 Object Replication Configuration
---

This incident type involves issues with replicating objects in Amazon S3 buckets after configuring replication. Replication issues can be caused by various factors, such as incorrect bucket ARN, incorrect key name prefix, suspended versioning, and missing permissions. Troubleshooting tips involve checking the replication status, verifying configuration settings, and ensuring that necessary permissions are granted. Replication time can also vary depending on the object size and source-destination region pair.

### Parameters
```shell
export OBJECT_KEY="PLACEHOLDER"

export BUCKET_NAME="PLACEHOLDER"

export REPLICATION_ROLE_ARN="PLACEHOLDER"

export DESTINATION_BUCKET_NAME="PLACEHOLDER"

export DESTINATION_BUCKET_ARN="PLACEHOLDER"
```

## Debug

### Check replication status of a specific object
```shell
aws s3api head-object --bucket ${BUCKET_NAME} --key ${OBJECT_KEY} --query "ReplicationStatus"
```

### List all versions of an object
```shell
aws s3api list-object-versions --bucket ${BUCKET_NAME} --prefix ${OBJECT_KEY}
```

### List all replication configurations for a bucket
```shell
aws s3api get-bucket-replication --bucket ${BUCKET_NAME}
```

### Check if versioning is enabled for a bucket
```shell
aws s3api get-bucket-versioning --bucket ${BUCKET_NAME}
```

### Get bucket policy for a specific bucket
```shell
aws s3api get-bucket-policy --bucket ${BUCKET_NAME}
```

### Check if a specific bucket policy statement grants s3:ObjectOwnerOverrideToBucketOwner permission
```shell
aws s3api get-bucket-policy --bucket ${DESTINATION_BUCKET_NAME} | jq -r '.Policy' | jq 'select(.Statement[] | select(.Effect == "Allow" and .Action == "s3:ObjectOwnerOverrideToBucketOwner"))'
```

## Repair

### Update or Verify that the ARN of the destination bucket is correct in the replication configuration on the source bucket.
```shell


#!/bin/bash



# Set variables

source_bucket=${BUCKET_NAME}

destination_bucket=${DESTINATION_BUCKET_ARN}

replication_role_arn=${REPLICATION_ROLE_ARN}



# Get the replication configuration of the source bucket

replication_config=$(aws s3api get-bucket-replication --bucket $source_bucket)



# Get the ARN of the destination bucket from the replication configuration

destination_bucket_arn=$(echo $replication_config | jq -r '.ReplicationConfiguration.Rules[].Destination.Bucket == "'$destination_bucket'") | .BucketArn')



if [ "$destination_bucket" != "$destination_bucket_arn" ]; then

  echo "Destination bucket ARN is incorrect in the replication configuration."

  echo "Updating the replication configuration with the correct ARN..."

  

  # Update the replication configuration with the correct destination bucket ARN

  aws s3api put-bucket-replication --bucket $source_bucket --replication-configuration "{\"Role\":\"$replication_role_arn\",\"Rules\":[{\"Status\":\"Enabled\",\"Destination\":{\"Bucket\":\"$destination_bucket\",\"Prefix\":\"\",\"Id\":\"default-rule\",\"Priority\":1}]}"

  

  echo "Replication configuration updated successfully."

else

  echo "Destination bucket ARN is correct in the replication configuration."

fi


```