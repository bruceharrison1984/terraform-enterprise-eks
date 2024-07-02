# Terraform Enterprise EKS Example

This repo is an amalagation of:

- <https://github.com/hashicorp/terraform-aws-terraform-enterprise/tree/main>
- <https://github.com/hashicorp/learn-terraform-provision-eks-cluster>

This is a fast-ish way to get Terraform Enterprise up and running in EKS for troubleshooting.

## Outputs

_Outputs will be used to configure the TFE FDO Helm charts._

After running `terraform apply` the outputs should resemble the following:

```sh
cluster_endpoint = "https://C564F705E81B02BC904D37BEEC40B63B.gr7.us-east-1.eks.amazonaws.com"
cluster_name = "tfe-eks-NCajJ9Nj"
cluster_security_group_id = "sg-06069950c27b54382"
object_store_hostname = "tfe-tfe-data.s3.us-east-1.amazonaws.com"
postgres_password = <sensitive>
postgres_username = "hashicorp"
postsgres_endpoint = "tfe-tfe20240702194900779000000001.cp0pum8d5fu1.us-east-1.rds.amazonaws.com:5432"
redis_hostname = "tfe-tfe.h8g6tm.ng.0001.use1.cache.amazonaws.com"
region = "us-east-1"
```

You can retrieve the Postgres password explicitly with `terraform output postgres_password`.
