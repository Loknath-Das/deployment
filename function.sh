#!/bin/bash

# Function to initiate k8s cluster connection
start_k8s() {

    if ! command -v kubectl &> /dev/null ; then
     echo "Kubectl not found. "
     exit 1
    else
     if kubectl cluster-info > /dev/null 2>&1; then
      echo "k8s cluster connection established."
     else
      echo "Failed to connect to k8s cluster."
      exit 1
     fi
    fi
}

# Following function will install helm and metric server
install_tools() {
 if ! command -v helm &> /dev/null ; then
   echo "Helm not found. Installing Helm."
   curl  https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
fi 

echo "Installing Metric server"
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
}


# Following function will create a namespace if it doesn't exist
k8s_namespace() {
    local namespace=$1
    if ! kubectl get namespace "$namespace" > /dev/null 2>&1; then
        echo "Namespace $namespace not found. Creating namespace."
        kubectl create namespace "$namespace"
        if [[ $? -ne 0 ]]; then
            echo "Failed to create namespace $namespace"
            exit 1
        fi
    else
        echo "Namespace $namespace already exists."
    fi
}

# Following function will create resources such as deployment, service, hpa

k8s_resources() {
    local namespace=$1
    shift
    local yaml_files=("$@")

    for yaml_files in "${yaml_files[@]}"; do
      kubectl apply -f "$yaml_files" -n "$namespace"
      if [[ $? -ne 0 ]]; then
        echo "Failed to apply $yaml_files in namespace $namespace"
        exit 1
      fi
    done

    echo "Resources created successfully in namesapce $namespace"
    deployment_info "$namespace" "$deployment_name"
}

# Following function will retrive deployment details, status, and health

deployment_info() {
  local namespace=$1
  local deployment_name=$2

  local deployment_info=$(kubectl get deployment "$deployment_name" -n "$namespace" -o json)
  local replicas=$(jq -r '.status.replicas' <<< "$deployment_info")
  local available_replicas=$(jq -r '.status.availableReplicas' <<< "$deployment_info")
  local deployment_status=$(jq -r '.status.conditions[] | select(.type=="Available").status' <<< "$deployment_info")

    echo "Deployment details in namespace $namespace:"
    echo "Deployment $deployment_name status: $available_replicas/$replicas replicas available."

    if [ "$deployment_status" == "True" ]; then
        echo "Deployment $deployment_name is healthy."
    else
        echo "Deployment $deployment_name is not healthy."
    fi
}


# Following function will create the dashboard

deployment_dashboard() {
    local namespace=$1
    local deployment_name=$2
    local status=""
    local deployment_info
    local replicas
    local available_replicas
    local deployment_status

    while true; do
        deployment_info=$(kubectl get deployment "$deployment_name" -n "$namespace" -o json)
        replicas=$(jq -r '.status.replicas' <<< "$deployment_info")
        available_replicas=$(jq -r '.status.availableReplicas' <<< "$deployment_info")
        deployment_status=$(jq -r '.status.conditions[] | select(.type=="Available").status' <<< "$deployment_info")

        status="Deployment $deployment_name status: ${available_replicas:-0}/${replicas:-0} replicas available.\n"

        if [ "$deployment_status" == "True" ]; then
            status+="Deployment $deployment_name is healthy."
            whiptail --title "Deployment Dashboard" --msgbox "$status" 10 60
            break
        else
            status+="Deployment $deployment_name is not healthy."
            whiptail --title "Deployment Dashboard" --msgbox "$status" 10 60
        fi

        sleep 2  
    done
}
