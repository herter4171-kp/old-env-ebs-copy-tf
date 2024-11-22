output "snapshot_arn" {
  value = aws_ebs_snapshot_copy.final.*.arn
}

output "kms_key_arn" {
  value = aws_kms_key.customer_managed_key.arn
}