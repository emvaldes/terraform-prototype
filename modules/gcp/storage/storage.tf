# File: modules/gcp/storage/storage.tf
# Version: 0.1.0

locals {

  # Extracting only bucket-related roles from the credentials
  valid_bucket_roles = flatten([
    for cred_key, cred in var.credentials : [
      for role in cred.roles :
      role.role if role.resource == "bucket"
    ]
  ])

  grouped_role_members = var.rbac_enabled ? {
    for group_key, profiles in var.group_credentials : group_key => {
      roles = merge([
        for profile_key, profile in profiles : {
          for role in profile.roles :
          role.role => role.resource == "bucket" ?
          "serviceAccount:${profile.name}@${var.project_id}.iam.gserviceaccount.com" :
          null
        }
      ]...)
    }
  } : {}

  merged_bucket_iam = var.rbac_enabled ? {
    for role_key in distinct(flatten([
      for group_profile in local.grouped_role_members :
      keys(group_profile.roles)
      ])) : role_key => compact([
      for group_profile in local.grouped_role_members :
      try(group_profile.roles[role_key], null)
    ])
  } : {}

}

# resource "google_storage_bucket_iam_binding" "bucket_bindings" {
#   for_each = local.merged_bucket_iam
#
#   bucket  = var.bucket_name
#   role    = each.key
#   members = each.value
# }

resource "google_storage_bucket_iam_binding" "bucket_bindings" {
  for_each = {
    for role_key, role_members in local.merged_bucket_iam :
    role_key => role_members
    if contains(local.valid_bucket_roles, role_key)
  }

  bucket  = var.bucket_name
  role    = each.key
  members = each.value
}
