locals {
  stage       = var.stage != "" ? var.stage : terraform.workspace
  dc          = "${var.provider_name}-${var.data_center}"
  host_suffix = "${local.dc}.${var.env}.${local.stage}"

  /* always add SSH, Tinc, Netdata, and Consul to allowed ports */
  open_tcp_ports = concat(["22", "655", "8000", "8301"], var.open_tcp_ports)
  open_udp_ports = concat(["655", "8301"], var.open_udp_ports)

  /* pre-generated list of hostnames */
  hostnames = toset([for i in range(1, var.host_count + 1) :
    "${var.name}-${format("%02d", i)}.${host_suffix}"
  ])
}

resource "hcloud_firewall" "host" {
  name = "${var.name}.${local.host_suffix}"

  /* TCP */
  dynamic "rule" {
    for_each = local.open_tcp_ports
    iterator = port
    content {
      direction = "in"
      protocol  = "tcp"
      port      = port.value
      source_ips = [
        "0.0.0.0/0",
        "::/0"
      ]
    }
  }

  /* UDP */
  dynamic "rule" {
    for_each = local.open_udp_ports
    iterator = port
    content {
      direction = "in"
      protocol  = "udp"
      port      = port.value
      source_ips = [
        "0.0.0.0/0",
        "::/0"
      ]
    }
  }
}

resource "hcloud_server" "host" {
  for_each     = local.hostnames
  name         = each.key
  image        = var.image
  server_type  = var.server_type
  datacenter   = var.data_center
  ssh_keys     = var.ssh_keys
  firewall_ids = [hcloud_firewall.host.id]
}

resource "hcloud_floating_ip" "host" {
  for_each  = local.hostnames
  server_id = hcloud_server.host[each.key].id
  type      = "ipv4"

  /* lifecycle { */
  /*   prevent_destroy = true */
  /* } */
}

/* Optional resource when data_vol_size is set */
resource "hcloud_volume" "host" {
  for_each  = local.hostnames
  name      = "data-${replace(each.key, ".", "-")}"
  server_id = hcloud_server.host[each.key].id
  size      = var.data_vol_size

  // TODO: disk will be mounted with a random name at /mnt
  // for example "/mnt/HC_Volume_10863580"
  // need to update infra-role-bootstrap / volumes task
  automount = true
  format    = "ext4"

  /* lifecycle { */
  /*   prevent_destroy = true */
  /*   /1* We do this to avoid destrying a volume unnecesarily *1/ */
  /*   ignore_changes = [ name ] */
  /* } */
}
