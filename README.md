# Deployment Status Monitoring Script Documentation

## Introduction

This script is designed to automate the deployment of Kubernetes resources and monitor the status of a specified deployment until it becomes healthy. It utilizes `kubectl` for managing Kubernetes resources and `whiptail` for creating a simple text-based dashboard to display the deployment status.

## Script Components

The script consists of two main parts:

1. **Function Definitions (`functions.sh`):**
   - Contains all the necessary functions required for managing Kubernetes resources and monitoring deployment status.

2. **Main Script (`main_script.sh`):**
   - Executes the main logic of the deployment and status monitoring process.
   - Utilizes functions defined in `functions.sh` for better code organization and reusability.

## Function Definitions (`functions.sh`)

1. **`start_k8s()`**
   - Initiates the Kubernetes cluster connection.
   - Checks if `kubectl` is installed and if the cluster connection is established.

2. **`install_tools()`**
   - Installs Helm and the Kubernetes Metrics Server if they are not already installed.

3. **`k8s_namespace(namespace)`**
   - Creates a namespace in Kubernetes if it doesn't already exist.

4. **`k8s_resources(namespace, yaml_files)`**
   - Creates Kubernetes resources (e.g., deployments, services, HPAs) in the specified namespace.
   - Applies YAML files containing resource definitions to the Kubernetes cluster.
   - Checks the success of applying each YAML file and prints an error message if unsuccessful.

5. **`deployment_info(namespace, deployment_name)`**
   - Retrieves deployment details, such as the number of replicas and the deployment status, in the specified namespace.
   - Checks if the deployment is healthy and prints the status.

6. **`deployment_dashboard(namespace, deployment_name)`**
   - Creates a dashboard to continuously monitor the deployment status until it becomes healthy.
   - Uses `whiptail` to display the deployment status in a text-based UI.
   - Updates the dashboard every 2 seconds to reflect any changes in the deployment status.

## Main Script (`main_script.sh`)

1. **Script Execution**
   - Sources the `functions.sh` file to access the defined functions.

2. **Execution Flow**
   - Initiates the Kubernetes cluster connection and installs necessary tools.
   - Sets the namespace and deployment name.
   - Creates the specified namespace in Kubernetes.
   - Defines paths to YAML files containing resource definitions.
   - Creates Kubernetes resources using the defined functions.
   - Retrieves and displays deployment information.
   - Monitors the deployment status using the dashboard function.

## Usage

- Run the `main_script.sh` script to execute the deployment and status monitoring process.
- Customize the namespace, deployment name, and YAML file paths as per your requirements.

## Dependencies

- Requires `kubectl`, `jq`, and `whiptail` to be installed on the system.
