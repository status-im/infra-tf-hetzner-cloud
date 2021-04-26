
terraform {
  required_version = "~> 0.14.4"
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "1.26.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "2.10.1"
    }
    ansible = {
      source  = "nbering/ansible"
      version = "1.0.4"
    }
  }
}
