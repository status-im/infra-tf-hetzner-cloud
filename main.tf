locals {
  stage = var.stage != "" ? var.stage : terraform.workspace

  /* we're prepending "eu-" to the location to keep the same format as our
   * other tf provider modules (aws, gcp, do ,...)
   * all hetzner cloud data centers are in the EU */
  dc = "${var.provider_name}-eu-${var.location}"

  /* example: stable-large-01.he-eu-hel1.nimbus.default */
  host_suffix = "${local.dc}.${var.env}.${local.stage}"

  /* always add SSH, Tinc, Netdata, and Consul to allowed ports */
  open_tcp_ports = concat(["22", "655", "8000", "8301"], var.open_tcp_ports)
  open_udp_ports = concat(["655", "8301"], var.open_udp_ports)

  /* pre-generated list of hostnames */
  hostnames = toset([for i in range(1, var.host_count + 1) :
    "${var.name}-${format("%02d", i)}.${local.host_suffix}"
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
  location     = var.location
  ssh_keys     = var.ssh_keys
  firewall_ids = [hcloud_firewall.host.id]

  /* bootstraping access for later Ansible use */
  provisioner "ansible" {
    plays {
      playbook {
        file_path = "${path.cwd}/ansible/bootstrap.yml"
      }

      hosts  = [self.ipv4_address]
      groups = [var.group]

      extra_vars = {
        hostname         = self.name
        data_center      = local.dc
        stage            = local.stage
        env              = var.env
        ansible_ssh_user = var.ssh_user
      }
    }
  }
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
  for_each  = toset([for h in local.hostnames : h if var.data_vol_size != 0])
  name      = "data-${replace(each.key, ".", "-")}"
  server_id = hcloud_server.host[each.key].id
  size      = var.data_vol_size

  /* lifecycle { */
  /*   prevent_destroy = true */
  /*   /1* We do this to avoid destrying a volume unnecesarily *1/ */
  /*   ignore_changes = [ name ] */
  /* } */
}

resource "cloudflare_record" "host" {
  for_each = local.hostnames
  zone_id  = var.cf_zone_id
  name     = hcloud_server.host[each.key].name
  value    = hcloud_floating_ip.host[each.key].ip_address
  type     = "A"
  ttl      = 3600
}

resource "ansible_host" "host" {
  for_each           = local.hostnames
  inventory_hostname = hcloud_server.host[each.key].name

  groups = [var.group, local.dc]

  vars = {
    ansible_host = hcloud_floating_ip.host[each.key].ip_address

    hostname = hcloud_server.host[each.key].name
    region   = hcloud_server.host[each.key].location

    dns_entry   = "${hcloud_server.host[each.key].name}.${var.domain}"
    dns_domain  = var.domain
    data_center = local.dc
    stage       = local.stage
    env         = var.env
  }
}
