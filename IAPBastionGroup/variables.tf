variable "members" {
  description = "List of members in the standard GCP form: user:{email}, serviceAccount:{email}, group:{email}"
  default     = []
}

variable "target_size" {
  description = "Number of instances to create"
  default     = 2
}
variable "project" {
  description = "Project ID where the bastion will run"
  type        = string
}

variable "region" {
  description = "Region where the bastion will run"
  default     = "northamerica-northeast1"
}

variable "zone" {
  description = "Zone where they bastion will run"
  default     = "northamerica-northeast1-a"
}

variable "network" {
  description = "VPC network where Bastion group will be deployed"

}

variable "subnet" {
  description = "Subnet where Bastion group will be deployed"
  
}
