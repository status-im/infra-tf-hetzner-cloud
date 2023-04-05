terraform {
  required_version = "> 1.4.0"
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "= 1.27.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "= 3.26.0"
    }
    ansible = {
      source  = "nbering/ansible"
      version = "= 1.0.4"
    }
  }
}
