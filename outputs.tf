output "hosts" {
  value = {
    for instance in hcloud_server.host :
    instance.name => hcloud_floating_ip.host[instance.name].ip_address
  }
}
