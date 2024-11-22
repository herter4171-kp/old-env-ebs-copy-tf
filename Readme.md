#ebs_copy_tf
This is a simple repo to share EBS snapshots from the old env to the new.  The basic sequence is
1. Copy the snapshot to encrypt it with our CMK
2. Share the copy with our desired external accounts
3. Feed snapshot and account IDs into `aws_snapshot_create_volume_permission` 

Currently, we can see the EBS volumes in the new environment and are allowed to create a volume with an ID assigned, but it fails quickly without populating the console.  The HCL for the new environment being used via Terragrunt can be found [here](https://github.com/KPInfr/terraform-aws-kp-storage/tree/polybucket_Fsx/modules/ebs_snapshot_volumizer).