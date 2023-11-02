

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