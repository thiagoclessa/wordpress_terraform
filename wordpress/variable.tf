variable "image" {
    default = "ami-026b57f3c383c2eec"
    type = string
}
variable "host" {
    default = "t2.micro"
    type = string
}
variable "path" {
    default = "/var/www/html"
    type =  string
}

variable "subnet_count" {
  type = map(number)
  default = {
    "public" = 1,
    "private"= 2
  }
  
}
variable "availabilityZone" {
     default = "us-east-1a"
     type = string
}
variable "instanceTenancy" {
    default = "default"
    type = string
}
variable "dnsSupport" {
    default = true
    type = string
}
variable "dnsHostNames" {
    default = true
    type = string
}
variable "vpcCIDRblock" {
    default = "10.141.0.0/16"
}
variable "publicsCIDRblock" {
    default = "10.141.50.0/24"
}
variable "privatesCIDRblock" {
    type = list(string)
    default = [
      "10.141.51.0/24",
      "10.141.52.0/24",
    ]
}

variable "storage" {
  default = 10
}
variable "engine" {
  default = "mysql"
}
variable "dbname" {
  default = "wordpress"
}
variable "db_instance" {
  default = "db.t2.micro"
}
variable "userdb" {
  default = "worduser"
}
variable "passdb" {
  default = "wordpass"
}
variable "engineversion" {
  default = "5.7"
}
variable "paremeter" {
  default = "wordmysql_5.7"
}

variable "VCP_ID" {
  default = "vpc-0988d86e7ed34b32c"
}

variable "RTC_PUB" {
  default = "rtb-05a2d25f2bafbeec1"
}