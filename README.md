# Project X - Documentation

## Description

This repository contains a Terraform script for setting up our infrastructure on AWS.

## Installation

- Run `./setup-terraform.sh` in root to install Terraform.
- Run `./setup-aws-cli.sh` in root to install the AWS CLI.

## Running the Script

- Run `terraform init` to download the Terraform provider for AWS.
- Run `terraform apply` to setup or update the infrastruture (type "yes" to confirm).
- Run `terraform destroy` to destroy the infrastructure (type "yes" to confirm).