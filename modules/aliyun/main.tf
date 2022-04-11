resource "alicloud_instance" "instance" {
  # count                = var.instance_number
  availability_zone = var.availability_zone
  # alicloud_security_group.default.*.id 安全组id
  security_groups = var.security_group_id
  instance_type        = var.instance_type
  system_disk_category = var.system_disk_category
  image_id             = var.image_id
  instance_name        = var.app_name
  vswitch_id = var.vswitch_id
  # 设置带宽大于1， 则自动分配公网IP
  internet_max_bandwidth_out = var.bandwidth_out
  key_name   = var.ssh_key_name
  resource_group_id = var.resource_group_id
}

resource "ansible_host" "cmp" {
  # count                = var.instance_number
  inventory_hostname = var.bandwidth_out >= 1 ? alicloud_instance.instance.public_ip : alicloud_instance.instance.private_ip
  groups             = [format("%s",var.app_name)]
  vars = {
      public_ip = alicloud_instance.instance.public_ip
      private_ip = alicloud_instance.instance.private_ip
    }
}

output "public_ip" {
  value = alicloud_instance.instance.public_ip
}

output "private_ip" {
  value = alicloud_instance.instance.private_ip
}
