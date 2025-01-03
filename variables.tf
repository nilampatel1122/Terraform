# Define variables

variable "cidr" {
  default = "10.0.0.0/16"

}

variable "aws_region" {
  type = string
}

variable "aws_access_key" {
  type = string

}

variable "aws_secret_key" {
  type = string

}

#variable "public_subnet_ids" {
#   type = list(string)

#}
