# Terraform setup

1. Access your DigitalOcean Account
    1. Don't have a DigitalOcean account? Try one for [free for 60 days](https://do.co/mason)
        1. The credits from this will be enough for this workshop
    1. If you have a DO account, we'll provide you credits
1. Create a [Personal Access Token](https://docs.digitalocean.com/reference/api/create-personal-access-token/)
1. Set your personal access token as an env var
    ```bash
    export TF_VAR_do_token=<YOUR TOKEN>
    ```
1. Setup Droplet Login
    1. Find Your SSH Keys in the [console](https://cloud.digitalocean.com/account/security)
        1. Get the name of your SSH key
        1. Set it as an environment variable
        ```bash
        export TF_VAR_ssh_key_name
        ```
    1. If you don't have an SSH key, upload one and follow the steps above
    1. If you don't know how to do this, ask one of the instructors
1. Run Terraform
    1. Terraform init - Initial Terraform setup
    ```bash
    terraform init
    ```
    1. Terraform plan - Verify your token works and you get an output
    ```bash
    terraform plan
    ```
    1. Terraform apply - Stand up the Droplet
        1. The cloud init scripts that install packages can take a bit, wait
        ~ 3-5 minutes before checking if the packages are installed   
        ```bash
        terraform apply
        ```
    1. Terraform destroy - Destroy the image when your done to not incur charges
    ```bash
    terraform destroy
    ```
