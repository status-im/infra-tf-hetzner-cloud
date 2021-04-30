#!/usr/bin/env bash
set -euo pipefail

# temporarily configure IP so that we don't have to restart the server
# https://docs.hetzner.com/cloud/floating-ips/faq/
ip addr add ${floating_ip}/32 dev eth0

# permanent config
# https://docs.hetzner.com/cloud/floating-ips/persistent-configuration
# will be applied after reboot
cat > /etc/netplan/60-floating-ip.yaml <<EOT
network:
  version: 2
  ethernets:
    eth0:
      addresses:
        - ${floating_ip}/32
EOT
