variable "mysql_password" {
  default = "snipeit"
  type = string
}

variable "mysql_dbname" {
    default = "snipeit"
    type = string
    sensitive = true
}


variable "username" {
    default = "snipeit"
    type = string
    sensitive = true
}
