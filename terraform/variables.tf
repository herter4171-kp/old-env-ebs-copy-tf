variable "aws_region" {
  default = "us-gov-east-1"
}

variable "allowed_accounts" {
  type    = list(string)
  default = ["289344444521", "289393653194", "289382756206"] # Shared, prod, dev
}

variable "volume_ids" {
  type    = list(string)
  default = ["vol-0a081128b127a1337"]
}
