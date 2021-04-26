# Usage

Simply import the modue using the source directive:

```hcl
module "hetzner-cloud" {
  source = "github.com/status-im/infra-tf-hetzner-cloud"
}
```

# Adding an SSH Key

```bash
$ hcloud ssh-key create --name bob --public-key-from-file ~/.ssh/id_rsa.pub
SSH key 1234567 created
```
