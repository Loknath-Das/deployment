#!/bin/bash

source function.sh

# script execution
start_k8s
install_tools

# namspace name and deployment name can be set here
namespace="simplismart"
deployment_name="app-deployment"
k8s_namespace "$namespace"

# YAML files
deployment_file="/home/loknath/Project/deployment.yml"
service_file="/home/loknath/Project/service.yml"
hpa_file="/home/loknath/Project/hpa.yml"
yaml_files=("$deployment_file" "$service_file" "$hpa_file")

# creating resources in k8s
k8s_resources "$namespace" "${yaml_files[@]}"

# status of the deployment
deployment_info "$namespace" "$deployment_name"

deployment_dashboard "$namespace" "$deployment_name"
