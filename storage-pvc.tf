# Resource: Kubernetes Storage Class


resource "kubernetes_storage_class_v1" "efs_sc" {  
  metadata {
    name = "efs-sc"
  }
  storage_provisioner = "efs.csi.aws.com"  
  parameters = {
    provisioningMode = "efs-ap"
    fileSystemId =  aws_efs_file_system.efs_file_system.id 
    directoryPerms = "700"
    gidRangeStart = "1000" # optional
    gidRangeEnd = "2000" # optional
    basePath = "/dynamic_provisioning" # optional
  }
}

# Resource: Persistent Volume Claim
resource "kubernetes_persistent_volume_claim_v1" "efs_pvc" {
  metadata {
    name = "efs-claim"
  }
  spec {
    access_modes = ["ReadWriteMany"]
    storage_class_name = kubernetes_storage_class_v1.efs_sc.metadata[0].name 
    resources {
      requests = {
        storage = "5Gi"
      }
    }
  }
}

# Storage Size (storage = "5Gi")
## You can specify any size for the persistent volume in the storage field. 
## Kubernetes requires this field, but because Amazon EFS is an 
## elastic file system, it does not enforce any file system capacity. 
