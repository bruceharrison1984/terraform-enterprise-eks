# Terraform Enterprise EKS Example

## **This should not be considered a Production ready instance of TFE, this is purely for exploratory/troubleshooting use**

This repo is an amalagation of:

- <https://github.com/hashicorp/terraform-aws-terraform-enterprise/tree/main>
- <https://github.com/hashicorp/learn-terraform-provision-eks-cluster>

This is a fast-ish way to get Terraform Enterprise up and running in EKS for troubleshooting.

## Outputs

The outputs from this module will be rendered into `override.yaml`. You can directly use this file to run the TFE Helm charts against the created EKS cluster.

## TFE Helm Charts

See the offical [TFE Helm Charts repository](https://github.com/hashicorp/terraform-enterprise-helm) to get the charts to install TFE.

## Kubectl Configuration

[Taken from Hashicorp EKS Tutorial](https://developer.hashicorp.com/terraform/tutorials/kubernetes/eks#configure-kubectl)

Run the following command to retrieve the access credentials for your cluster and configure kubectl.

```
aws eks --region $(terraform output \
        -raw region) update-kubeconfig \
        --name $(terraform output -raw cluster_name)
```

## Quick Start

After establishing `kubectl` functionality, setup EKS to run TFE

```sh
## create namespace
kubectl create namespace terraform-enterprise

## create TFE image pull secret (presumes TFE license is located at ./terraform.hclic)
kubectl create secret docker-registry terraform-enterprise --docker-server=images.releases.hashicorp.com --docker-username=terraform --docker-password=$(cat ./terraform.hclic)  -n terraform-enterprise
```

Copy `override.yaml` into the offical TFE Helm chart repo and then run the following to deploy it:

```sh
helm install terraform-enterprise . --values ./override.yaml -n terraform-enterprise
```

## Issues

- Upon deletion, EKS will not cleanup up ALBs that were created. These need to be manually removed before the VPC can be fully destroyed.

## Helpful Commands

### Watch raw TFE logs as container comes up

```sh
while true; do sleep 1; kubectl exec -n terraform-enterprise -ti $(kubectl get pods -n terraform-enterprise | tail -1 | awk '{print $1}') -- tail -n 100 -f /var/log/terraform-enterprise/terraform-enterprise.log; done
```

## Get a debian shell inside EKS to check connectivity, etc

```sh
kubectl run support -i --tty -n terraform-enterprise --image debian:bullseye --restart=Never -- bash
```
