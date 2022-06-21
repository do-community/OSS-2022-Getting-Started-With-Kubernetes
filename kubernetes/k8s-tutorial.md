# Deploying an Application to Kubernetes

## Prerequisites

### Instructions
1. Create a Kubernetes Cluster from the DigitalOcean Control Panel
    1. From the Create menu in the control panel, click Kubernetes.
    1. Select a Kubernetes version. The latest version is selected by default and is the best choice if you have no specific need for an earlier version.
    1. Choose a datacenter region.
    1. Customize the default node pool, choose the node pool names, and add additional node pools.
    1. Name the cluster, select the project you want the cluster to belong to, and optionally add a tag. Any tags you choose will be applied to the cluster and its worker nodes.
    1. Click Create Cluster. Provisioning the cluster takes several minutes.
    1. Download the cluster configuration file by clicking Actions, then Download Config from the cluster home page.

1. Once the cluster is created, use `kubectl` to check verify that you can connect to the cluster. 
    ```shell
    kubectl get nodes
    ```

Your should see output like this: 
    ```shell
    List of nodes here. 
    ```

1. Create a namespace where you will deploy your application
    ```shell
    kubectl apply -f kubernetes/manifests/namespace.yaml
    ```

Check that your new namespace exists by running 
    ```shell
    kubectl get namespaces
    ```
1. Create a Kubernetes Deployment that will ensure there 3 replicas of the One Time Secret application running at once 
    ```shell
    kubectl apply -f kubernetes/manifests/deployment.yaml
    ```
Check that there are three `one-time-secret` pod running in your `app-namespace` namespace.
    ```shell
    kubectl get po -n app-namespace
    ```

1. Verify your application works in the cluster 


1. Deploy a service to exposer your application replicas to the internet 

1. Add resource requests and limits

1. Tear down your cluster






