locals {
  ignition_encoded = "data:text/plain;charset=utf-8;base64,${base64encode(var.ignition)}"
}

data "ignition_file" "hostname" {

  path = "/etc/hostname"
  mode = "775"

  content {
    content = var.name
  }
}

data "ignition_file" "opflexroute" {
  path = "/etc/NetworkManager/dispatcher.d/80-opflex-route"
  mode = "493"
  content  {
     content = "#!/bin/bash\n if [ \"$1\" == \"ens224.${var.infravlan}\" ] && [ \"$2\" == \"up\" ]; then \n route add -net 224.0.0.0 netmask 240.0.0.0 dev ens224.3901 \n fi\n"

  }
}

data "ignition_config" "vm" {

  merge {
    source = local.ignition_encoded
  }
  files = [
    data.ignition_file.hostname.rendered,
    data.ignition_file.opflexroute.rendered
  ]
}

resource "vsphere_virtual_machine" "vm" {

  name               = var.name
  resource_pool_id   = var.resource_pool_id
  datastore_id       = var.datastore
  num_cpus           = var.num_cpu
  memory             = var.memory
  memory_reservation = var.memory
  guest_id           = var.guest_id
  folder             = var.folder
  enable_disk_uuid   = "true"

  wait_for_guest_net_timeout  = "0"
  wait_for_guest_net_routable = "false"

  network_interface {
    network_id   = var.api_network_id
    adapter_type = var.adapter_type
  }

  network_interface {
    network_id   = var.opflex_network_id
    adapter_type = var.adapter_type
  }

  disk {
    label            = "disk0"
    size             = var.disk_size
    thin_provisioned = var.thin_provisioned
  }

  clone {
    template_uuid = var.template
  }

  extra_config = {
    "guestinfo.ignition.config.data"          = base64encode(data.ignition_config.vm.rendered)
    "guestinfo.ignition.config.data.encoding" = "base64"

    # configures the static IP
    # https://www.man7.org/linux/man-pages/man7/dracut.cmdline.7.html
    #"guestinfo.afterburn.initrd.network-kargs" = "ip=${var.ipv4_address}::${var.gateway}:${var.netmask}:${var.name}:ens192:off:${var.dns_address}"
    "guestinfo.afterburn.initrd.network-kargs" = "ip=${var.ipv4_address}::${var.gateway}:${var.netmask}:${var.name}:ens192:off:${var.dns_address} ip=ens224:off:${var.opflex_mtu_size} vlan=ens224.${var.infravlan}:ens224 ip=ens224.${var.infravlan}:dhcp:${var.opflex_mtu_size}"
  }
}
