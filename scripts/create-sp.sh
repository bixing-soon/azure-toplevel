#!/bin/bash

if ! command -v az; then
    echo "Azure CLI is not installed. Please install it first."
    exit 1
fi

read -rp "Service Principal Name: " SP_NAME
read -rp "Role: " ROLE

az ad sp create-for-rbac -n $SP_NAME --role $ROLE --scopes /subscriptions/$(az account show --query id -o tsv) --create-cert
