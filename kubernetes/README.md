# Deploying an Application to Kubernetes

## Prerequisites
- [A DigitalOcean Account](https://cloud.digitalocean.com/registrations/new)
- [doctl](https://docs.digitalocean.com/reference/doctl/how-to/install/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [httpie](https://httpie.io/docs/cli/installation)

### Instructions
1. [Create a Kubernetes Cluster from the DigitalOcean Control Panel](https://docs.digitalocean.com/products/kubernetes/how-to/create-clusters/)
    1. From the Create menu in the [control panel](https://cloud.digitalocean.com/), click Kubernetes.
    1. Select a Kubernetes version. The latest version is selected by default and is the best choice if you have no specific need for an earlier version.
    1. Choose a datacenter region.
    1. Customize the default node pool, choose the node pool names, and add additional node pools.
    1. Name the cluster, select the project you want the cluster to belong to, and optionally add a tag.
    1. Click Create Cluster. Provisioning the cluster takes several minutes.
    1. Download the cluster configuration file by clicking Actions, then Download Config from the cluster home page.

1.  Configure `doctl` 
    1. [Create an API token](https://cloud.digitalocean.com/account/api/)
    1. Export your token as an environment variable called `DO_TOKEN`.
    ```sh
    export DO_TOKEN="<YOUR_DO_TOKEN>"
    ```

        **Note:** Since Windows doesn't support enviornment variables, Windows users should keep the token on their clipboard to easily paste.

    1. [Use the API token to grant account access to doctl](https://docs.digitalocean.com/reference/doctl/how-to/install/#step-3-use-the-api-token-to-grant-account-access-to-doctl)
    ```sh
    doctl auth init 
    ```
    1. [Validate that doctl is working](https://docs.digitalocean.com/reference/doctl/how-to/install/#step-4-validate-that-doctl-is-working)
    ```sh
    doctl account get
    ```

    You should see output like this: 

    ```sh
    Email                            Droplet Limit    Email Verified    UUID                                    Status
    kschlesinger@digitalocean.com    25               true              4ba4b281-ie98-4888-a843-2365cf961232    active
    ```

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

    You should see a list of namespaces, including the `app-namespace`, like this:
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
    You should see something like this:
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
        
        You will see something like this:
        
        ```shell
        NAME                              READY   STATUS    RESTARTS   AGE
        one-time-secret-5b757b96f-6nbm7   1/1     Running   0          10m
        one-time-secret-5b757b96f-b9t54   1/1     Running   0          10m
        one-time-secret-5b757b96f-cjtsx   1/1     Running   0          10m
        utilities-6d8f574894-kt59m        1/1     Running   0          10s
        ```
    1. Exec into that pod 
        ```shell
        k exec -it <utilities_pod_name> -n app-namespace -- /bin/sh
        ```
    1. Install `httpie`
        ```shell
        curl -SsL https://packages.httpie.io/deb/KEY.gpg | apt-key add - && curl -SsL -o /etc/apt/sources.list.d/httpie.list https://packages.httpie.io/deb/httpie.list && apt update && apt install httpie
        ```
    1.  Test write 
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

1. Deploy a service to create a Load Balancer that will direct traffic from the internet to your application replicas 
    ```shell
    kubectl apply -f kubernetes/manifests/service.yaml
    ```
    Find the external IP address of the Load Balancer
    ```shell
    kubectl get svc -A
    ```
    You will see something like this:
    ```shell
    NAMESPACE       NAME          TYPE           CLUSTER-IP      EXTERNAL-IP      PORT(S)                  AGE
    app-namespace   ots-service   LoadBalancer   10.245.26.224   143.198.247.38   80:31965/TCP             60m
    default         kubernetes    ClusterIP      10.245.0.1      <none>           443/TCP                  2d12h
    kube-system     kube-dns      ClusterIP      10.245.0.10     <none>           53/UDP,53/TCP,9153/TCP   2d12h
    ```
    It takes a few minutes for Load Balancer to be created and be assigned an IP address. 


1. Use `httpie` to verify your application works over the internet
    1.  Test write 
        ```bash
        http POST <load_balancer_ip_address>/secrets message="YOUR_MESSAGE" passphrase="YOUR_PASSPHRASE"
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
        http POST <load_balancer_ip_address/secrets/<id> passphrase="YOUR_PASSPHRASE"
        ```
        1. Sample Response
        ```json
        {
            "message": "Hello there",
            "success": "True"
        }
        ```

1. Add resource requests and limits
    1. In the [Deployment manifest](./manifests/deployment.yaml), uncomment lines 25-31.
    1. Update the Deployment with 
    ```shell
    kubectl apply -f kubernetes/manifests/deployment.yaml
    ```

1. [Destroy your cluster](https://docs.digitalocean.com/products/kubernetes/how-to/destroy-clusters/)
    1. Go to the Kubernetes page in the control panel. From the cluster’s More menu, select Destroy and click Destroy. 
    1. In the Destroy Kubernetes cluster dialog box, select the resources, such as load balancers and block storage volumes, associated with the cluster to delete them automatically when the cluster is deleted. Enter the name of the cluster, then click Destroy to confirm.

1. Congrats! You just deployed an application to Kubernetes and directed traffic to it from the internet! 🎉






