# Deploying an Application to Kubernetes

## Prerequisites
- [A DigitalOcean Account](https://cloud.digitalocean.com/registrations/new)
- [doctl](https://docs.digitalocean.com/reference/doctl/how-to/install/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [httpie](https://httpie.io/docs/cli/installation)

### Instructions
1. Create a Kubernetes Cluster from the [DigitalOcean Control Panel](https://cloud.digitalocean.com/)
    1. From the Create menu in the control panel, click Kubernetes.
    1. Select a Kubernetes version. The latest version is selected by default and is the best choice if you have no specific need for an earlier version.
    1. Choose a datacenter region.
    1. Customize the default node pool, choose the node pool names, and add additional node pools.
    1. Name the cluster, select the project you want the cluster to belong to, and optionally add a tag.
    1. Click Create Cluster. Provisioning the cluster takes several minutes.
    1. Download the cluster configuration file by clicking Actions, then Download Config from the cluster home page.

1. Once the cluster is created, use `kubectl` to verify that you can connect to the cluster. 
    ```shell
    kubectl get nodes
    ```

You should see output like this: 
    ```shell
    NAME                   STATUS   ROLES    AGE     VERSION
    pool-vj14tarbi-csyw0   Ready    <none>   30s   v1.22.8
    pool-vj14tarbi-csyw1   Ready    <none>   30s   v1.22.8
    pool-vj14tarbi-csywd   Ready    <none>   30s   v1.22.8
    ```

1. Create a namespace where you will deploy your application
    ```shell
    kubectl apply -f kubernetes/manifests/namespace.yaml
    ```

    Check that your new namespace exists by running 
    ```shell
    kubectl get namespaces
    ```

    You should see a list of namespaces, including the `app-namespace`, like this
    ```shell
    NAME              STATUS   AGE
    app-namespace     Active   3s
    default           Active   10m
    kube-node-lease   Active   10m
    kube-public       Active   10m
    kube-system       Active   10m
    ```
1. Create a Kubernetes Deployment that will ensure there 3 replicas of the One Time Secret application running at once.
    ```shell
    kubectl apply -f kubernetes/manifests/deployment.yaml
    ```
    Check that there are three `one-time-secret` pods running in your `app-namespace` namespace.
    ```shell
    kubectl get pods -n app-namespace
    ```
    You should see something like this
    ```shell
    NAME                              READY   STATUS    RESTARTS   AGE
    one-time-secret-5b757b96f-6nbm7   1/1     Running   0          12s
    one-time-secret-5b757b96f-b9t54   1/1     Running   0          12s
    one-time-secret-5b757b96f-cjtsx   1/1     Running   0          12s
    ```

1. Use `httpie` to verify your application works in the cluster 
    1. Find the IP address of your pod and copy one address to your clipboard
    ```shell
    kubectl get pods -n app-namespace -o wide
    ```

    1. Create a utilities pod
    ```shell
    kubectl apply -f kubernetes/manifests/utilities.yaml
    ```
        1. Get the unique id of the pod and copy that to your clipboard.
        ```shell
        kubectl get pods -n app-namespace
        ```
        
        You will see something like this
        ```shell
        NAME                              READY   STATUS    RESTARTS   AGE
        one-time-secret-5b757b96f-6nbm7   1/1     Running   0          10m
        one-time-secret-5b757b96f-b9t54   1/1     Running   0          10m
        one-time-secret-5b757b96f-cjtsx   1/1     Running   0          10m
        utilities-6d8f574894-kt59m        1/1     Running   0          10s
        ```
    1. Exec into that pod 
        ```shell
        k exec -it <utilities_pod> -n app-namespace -- /bin/sh
        ```
    1. Install `httpie`
        ```shell
        curl -SsL https://packages.httpie.io/deb/KEY.gpg | apt-key add - && curl -SsL -o /etc/apt/sources.list.d/httpie.list https://packages.httpie.io/deb/httpie.list && apt update && apt install httpie
        ```
    1.  1. Test write 
        ```bash
        http POST <pod_ip_address>:8080/secrets message="YOUR_MESSAGE" passphrase="YOUR_PASSPHRASE"
        ```
        1. Sample Response
        ```json
        {
           "id": "ea54d2701885400cafd0c11279672c8f",
           "success": "True"
        }
        ```
    1. Test read, using the id from above
        ```bash
        http POST <pod_ip_address>:8080/secrets/<id> passphrase="YOUR_PASSPHRASE"
        ```
        1. Sample Response
        ```json
        {
            "message": "Hello there",
            "success": "True"
        }
        ```
    1. Exit out of the utilities pod
        ```shell
        exit
        ```


1. Deploy a service to expose your application replicas to the internet 
    ```shell
    kubectl apply -f kubernetes/manifests/service.yaml
    ```
    
1. Use `httpie` to verify your application works over the internet

1. Add resource requests and limits

1. Tear down your cluster





