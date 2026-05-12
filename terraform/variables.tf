############################################################
# VARIABLES
############################################################

variable "region" {
  default = "us-west-2"
}

variable "container_port" {
  default = 80
}

variable "desired_count" {
  default = 1
}
