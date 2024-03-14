/* DNS ------------------------------------------*/

variable "cf_zone_id" {
  description = "ID of CloudFlare zone for host record."
  type        = string
  default     = "fd48f427e99bbe1b52105351260690d1"
}

variable "domain" {
  description = "DNS Domain to update"
  type        = string
  default     = "status.im"
}

/* SCALING ---------------------------------------*/

variable "host_count" {
  description = "Number of hosts to run."
  type        = number
  default     = 1
}

/* Use: `hcloud server-type list` */
variable "type" {
  description = "Type of machine to deploy."
  type        = string
  default     = "cx11"
}

/* Used to create extra data volume */
variable "data_vol_size" {
  description = "Size of the extra data volume."
  type        = number
  default     = 0
}

/* Use: `hcloud location list` */
variable "location" {
  description = "Location in which to deploy hosts."
  type        = string
  # Helsinki, Finland
  default     = "hel1"
}

/* Use: `hcloud image list` */
variable "image" {
  description = "OS image to use when deploying hosts."
  type        = string
  default     = "ubuntu-22.04"
}

variable "provider_name" {
  description = "Short name of the provider used."
  type        = string
  default     = "he"
}

/* GENERAL --------------------------------------*/

variable "name" {
  description = "Name for hosts. To be used in the DNS entry."
  type        = string
  default     = "node"
}

variable "env" {
  description = "Environment for these hosts, affects DNS entries."
  type        = string
}

variable "stage" {
  description = "Name of stage, like prod, dev, or staging."
  type        = string
  default     = ""
}

variable "group" {
  description = "Ansible group to assign hosts to."
  type        = string
}

variable "ssh_user" {
  description = "User used to log in to instance"
  type        = string
  default     = "root"
}

variable "ssh_keys" {
  description = "Names of ssh public keys to add to created hosts"
  type        = list(string)

  # get a list of all available keys: `hcloud ssh-key list`
  default     = [
    "jakub@status.im",
  ]
}

/* FIREWALL --------------------------------------*/

variable "open_tcp_ports" {
  description = "TCP ports to open in firewall."
  type        = list(string)
  default     = []
}

variable "open_udp_ports" {
  description = "UDP ports to open in firewall."
  type        = list(string)
  default     = []
}
