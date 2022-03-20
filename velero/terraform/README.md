# Terraform

These resources should be built with Terraform: https://terraform.io

Manage AWS S3 bucket with Terraform.

## AWS Provider

Use the Amazon Web Services (AWS) provider to interact with the many resources supported by AWS. 

# Deployment

## Configure AWS S3 and DynamoDB for Remote State Files

See configuration instructions here:

https://www.lisenet.com/2020/terraform-with-aws-s3-and-dynamodb-for-remote-state-files/

See required IAM account permissions [docs/terraform-aws-iam-permissions.json](../../docs/terraform-aws-iam-permissions.json).

## Apply Terraform Configuration

Requires Terraform v1.0 or above.

```
terraform init
terraform apply
```

# References

https://registry.terraform.io/providers/hashicorp/aws/latest/docs
