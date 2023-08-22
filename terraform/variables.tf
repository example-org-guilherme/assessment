variable "owner" {
    description = "Repositories owner"
}

variable "token" {
    description = "Token with Admin/Contents read-write access"
    sensitive = true
}

variable "state_path" {
    default = "/state/terraform.tfstate"
}