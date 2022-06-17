terraform {
    required_providers {
        digitalocean = {
            source = "digitalocean/digitalocean"
        }
    }
}

variable do_token {}
variable ssh_key_name{}

provider digitalocean {
    token = var.do_token
}

data "digitalocean_ssh_key" "home" {
    name = var.ssh_key_name
}

resource "digitalocean_droplet" "web" {
    image = "docker-20-04"
    name = "dev"
    region = "sfo3"
    size = "s-2vcpu-2gb-intel"
    ssh_keys = [data.digitalocean_ssh_key.home.id]

    user_data = <<EOF
#!/bin/bash
apt update && apt install httpie -y
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    EOF
}

output "server_ip" {
    value = digitalocean_droplet.web.ipv4_address
} 