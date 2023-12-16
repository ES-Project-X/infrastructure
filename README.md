# BiX - Infrastructure

## Description

This repository contains a Terraform script for setting up our infrastructure on AWS.

**Course:** Software Engineering (2023/2024).

## Installation

- Run `./setup-terraform.sh` in root to install Terraform.
- Run `./setup-aws-cli.sh` in root to install the AWS CLI.
- Run `./setup-aws-cli-after.sh` in root to authenticate the AWS CLI to the Elastic Container Repository, so that you are able to push Docker images to it (replace the ECR ID inside the script, after running `terraform apply`, with the ID shown in this command's output). 

## Running the Script

- Run `terraform init` to download the Terraform provider for AWS.
- Run `terraform apply` to setup or update the infrastruture (type "yes" to confirm).
- Run `terraform destroy` to destroy the infrastructure (type "yes" to confirm).
