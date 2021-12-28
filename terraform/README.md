# Terraform

These resources should be built with Terraform: https://terraform.io

Manage Kubernetes with Terraform. This effectivelly replaces all `kubectl` and `helm` commands with a single `terraform apply`.

## Kubernetes Provider

The Kubernetes provider is used to interact with the resources supported by Kubernetes. The provider needs to be configured with the proper credentials before it can be used.

## Kubectl Provider

This provider is likely the best way of managing Kubernetes resources in Terraform, by allowing you to use yaml.

## Helm Provider

The Helm provider is used to deploy software packages in Kubernetes.

# Deployment

## Configure AWS S3 and DynamoDB for Remote State Files

See configuration instructions here:

https://www.lisenet.com/2020/terraform-with-aws-s3-and-dynamodb-for-remote-state-files/

See required IAM account permissions [docs/terraform-aws-iam-permissions.json](../docs/terraform-aws-iam-permissions.json).

## Apply Terraform Configuration

Requires Terraform v1.0 or above.

Terraform has not been configured to create certain namespaces, therefore run the following:

```
$ kubectl create ns kubecost
$ kubectl create ns logging
$ kubectl create ns speedtest
```

Change to your project directory and run the following:

```
$ terraform init
$ terraform apply
```

# References

https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs

https://registry.terraform.io/providers/gavinbunney/kubectl/latest

https://registry.terraform.io/providers/hashicorp/helm/latest/docs