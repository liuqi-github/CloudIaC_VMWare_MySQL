resource "vsphere_virtual_machine" "vm" {
  count      = var.instance_number
  name             = var.instance_number > 1  ? format("%s%03d", var.app_name, count.index + 1) : var.app_name
  resource_pool_id = var.resource_pool_id
  datastore_id     = var.datastore_id
  wait_for_guest_net_timeout = 0
  # 用这个参数可以控制等待ip 出来的结果
  wait_for_guest_ip_timeout = 2
  num_cpus = var.num_cpus
  memory   = var.memory
  guest_id = var.guest_id

  network_interface {
    network_id = var.network_id
  }

  disk {
    label = var.disk_label
    size  = var.disk_size
    eagerly_scrub    = var.eagerly_scrub
    thin_provisioned = var.thin_provisioned
  }

  clone {
    template_uuid = var.template_uuid
    customize {
      linux_options {
        host_name = replace(var.instance_number > 1  ? format("%s%03d", var.app_name, count.index + 1) : var.app_name, "_", "-")
        domain    = var.domain
      }
      network_interface {
         ipv4_address = var.ipv4_address
         ipv4_netmask = var.ipv4_netmask
      }
      ipv4_gateway = var.ipv4_gateway
      dns_server_list = var.dns_server
    }
  }
}

resource "ansible_host" "cmp" {
  count                = var.instance_number
  inventory_hostname = vsphere_virtual_machine.vm[count.index].default_ip_address
  groups             = [format("%s",var.app_name)]
  vars = {
      private_ip = vsphere_virtual_machine.vm[count.index].default_ip_address
    }
}

output "vm_ip_address" {
  value = vsphere_virtual_machine.vm[0].default_ip_address
}