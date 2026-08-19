locals {
  public_ips = [
    for key, host in hcloud_server.host :
      try(hcloud_floating_ip.host[key].ip_address, host.ipv4_address)
  ]
  instance_ids = [
    for h in hcloud_server.host : h.id
  ]
}

output "public_ips" {
  value = local.public_ips
}

output "hostnames" {
  value = local.hostnames
}

output "hosts" {
  value = zipmap(local.hostnames, local.public_ips)
}

output "ids" {
  value = zipmap(local.hostnames, local.instance_ids)
}
