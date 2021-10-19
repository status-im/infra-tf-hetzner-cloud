# Usage

This is a helper module used by Status internal repos like: [infra-hq](https://github.com/status-im/infra-hq), [infra-misc](https://github.com/status-im/infra-misc), [infra-eth-cluster](https://github.com/status-im/infra-eth-cluster), or [infra-swarm](https://github.com/status-im/infra-swarm).

# Usage

Simply import the modue using the `source` directive:
```hcl
module "hetzner-cloud" {
  source = "github.com/status-im/infra-tf-hetzner-cloud"
}
```
[More details.](https://www.terraform.io/docs/modules/sources.html#github)

# Variables

* __Scaling__
  * `host_count` - Number of hosts to start in this region.
  * `image` - OS image used to create host. (default: `ubuntu-20.04`)
  * `type` - Type of host to create. (default: `cx11`)
  * `location` - Region in which the host will be created. (default: `hel1`)
  * `data_vol_size` - Size in GiB of an extra data volume to attach to the dropplet. (default: 0)
* __General__
  * `name` - Prefix of hostname before index. (default: `node`)
  * `group` - Name of Ansible group to add hosts to.
  * `env` - Environment for these hosts, affects DNS entries.
  * `stage` - Name of stage, like `prod`, `dev`, or `staging`.
  * `domain` - DNS Domain to update.
* __Security__
  * `ssh_user` - User used to log in to instance (default: `root`)
  * `ssh_keys` - Names of ssh public keys to add to created hosts.
  * `open_tcp_ports` - TCP port ranges to enable access from outside. Format: `N-N` (default: `[]`)
  * `open_udp_ports` - UDP port ranges to enable access from outside. Format: `N-N` (default: `[]`)

# Adding an SSH Key

```bash
$ hcloud ssh-key create --name bob --public-key-from-file ~/.ssh/id_rsa.pub
SSH key 1234567 created
```
