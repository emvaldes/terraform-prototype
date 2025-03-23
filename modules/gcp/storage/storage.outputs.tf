# File: modules/gcp/storage/storage.outputs.tf
# Version: 0.1.0

output "bucket_iam_bindings" {
  description = "All IAM bucket role bindings applied via RBAC (grouped by role)"
  value = {
    for role, binding in google_storage_bucket_iam_binding.bucket_bindings :
    role => {
      bucket  = binding.bucket
      role    = binding.role
      members = try(binding.members, null)
      etag    = binding.etag
    }
  }
}
