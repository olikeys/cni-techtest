// VPC variables
variable "man_pvt_subnets" {
    type = "list"
}
variable "man_pub_subnets" {
    type = "list"
}
variable "app_pvt_subnets" {
    type = "list"
}
variable "app_pub_subnets" {
    type = "list"
}

// Bastion variables
variable "bastion_instance_type" {}
variable "bastion_ami" {}
variable "bastion_key_name" {}
variable "bastion_iam_role_config" {
    type = "map"
}

variable "allowed_ip_ranges" {}