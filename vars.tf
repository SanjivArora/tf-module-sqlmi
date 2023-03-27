variable "create_resource_group" {
  description = "Whether to create resource group and use it for all resources"
  default     = false
  type        = bool
}

variable resource_group_name {
  type        = string
  default     = ""
  description = "Name of the Resource Group"
}

variable "location" {
  description = "The location/region to keep all your resources"
  default     = "australiaeast"
  type        = string
}

variable "location_short_ae" {
  description = "Short abbreviation of location"
  default     = "ae"
  type        = string
}

variable "environment" {
  description = "resources environment"
  default     = ""
  type        = string
}

variable solution {
  type        = string
  default     = ""
  description = "Name of the service or application"
}

variable "common_tags" {
  description = "Common tags applied to all the resources created in this module"
  type        = map(string)
}

variable sql_admin_password {
  type        = string
  default     = ""
  description = "Admin password for sqlmi"
}

variable sqlmi_subnet_id {
  type        = string
  default     = ""
  description = "Admin password for sqlmi"
}

variable keyvault_key_id {
  type        = string
  default     = ""
  description = "Keyvalut id of TDE CM keys"
}

variable storage_endpoint {
  type        = string
  default     = ""
  description = "Storage account primary blob endpoint"
}

variable sa_access_key {
  type        = string
  default     = ""
  description = "Storage account access key"
}

variable sa_conatiner_path {
  type        = string
  default     = ""
  description = "Storage account conatiner path to store assessment results"
}

variable ad_admin_group {
  type        = string
  default     = ""
  description = "AD group name to grant admin rights"
}

variable ad_admin_group_object_id {
  type        = string
  default     = ""
  description = "AD admin group object id to grant admin rights"
}