resource aws_snapshot_create_volume_permission "external" {
  count = length(var.account_ids)

  snapshot_id = var.snapshot_id
  account_id  = var.account_ids[count.index]
}