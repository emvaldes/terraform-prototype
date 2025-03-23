# File: modules/gcp/storage/storage.variables.tf
# Version: 0.1.0

variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "bucket_name" {
  description = "The name of the GCS bucket to apply IAM bindings to"
  type        = string
}

variable "rbac_enabled" {
  description = "Flag to enable IAM access control logic for the backend bucket"
  type        = bool
}

variable "backend_policy_bindings" {
  description = "Optional static IAM bindings (role => members[]) applied when RBAC is enabled"
  type = map(object({
    role    = string
    members = optional(list(string), [])
  }))
  default = {}
}

variable "credentials" {
  description = "Map of credential profiles (from profiles.json)"
  type = map(object({
    id           = string
    description  = string
    name         = string
    filename     = string
    environments = list(string)
    group        = optional(string)
    roles = list(object({
      resource = string
      role     = string
    }))
  }))
}

variable "group_credentials" {
  description = "Map of credential profiles grouped by 'group' key"
  type = map(map(object({
    id           = string
    description  = string
    name         = string
    filename     = string
    environments = list(string)
    roles = list(object({
      resource = string
      role     = string
    }))
  })))
}
