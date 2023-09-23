# Install EFS CSI Driver using HELM

# Resource: Helm Release 
resource "helm_release" "efs_csi_driver" {
  depends_on = [aws_iam_role.efs_csi_iam_role ]            
  name       = "aws-efs-csi-driver"

  repository = "https://kubernetes-sigs.github.io/aws-efs-csi-driver"
  chart      = "aws-efs-csi-driver"

  namespace = "kube-system"     

  set {
    name = "image.repository"
    value = "602401143452.dkr.ecr.us-east-1.amazonaws.com/eks/aws-efs-csi-driver" # Changes based on Region - This is for us-east-1 Additional Reference: https://docs.aws.amazon.com/eks/latest/userguide/add-ons-images.html
  }       

  set {
    name  = "controller.serviceAccount.create"
    value = "true"
  }

  set {
    name  = "controller.serviceAccount.name"
    value = "efs-csi-controller-sa"
  }

  set {
    name  = "controller.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = "${aws_iam_role.efs_csi_iam_role.arn}"
  }
    
}


# Datasource: EFS CSI IAM Policy get from EFS GIT Repo (latest)
data "http" "efs_csi_iam_policy" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-efs-csi-driver/master/docs/iam-policy-example.json"

  # Optional request headers
  request_headers = {
    Accept = "application/json"
  }
}


#####EF# Resource: Create EFS CSI IAM Policy 
resource "aws_iam_policy" "efs_csi_iam_policy" {
  name        = "${var.cluster_name}-AmazonEKS_EFS_CSI_Driver_Policy"
  path        = "/"
  description = "EFS CSI IAM Policy"
  policy = data.http.efs_csi_iam_policy.body
}



# Resource: Create IAM Role and associate the EFS IAM Policy to it
resource "aws_iam_role" "efs_csi_iam_role" {
  name = "${var.cluster_name}-efs-csi-iam-role"

  # Terraform's "jsonencode" function converts a Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Federated = "arn:aws:iam::967865641205:oidc-provider/${replace(aws_eks_cluster.eks_cluster.identity.0.oidc.0.issuer, "https://", "")}"
        }
        Condition = {
          StringEquals = {
            "${replace(aws_eks_cluster.eks_cluster.identity.0.oidc.0.issuer, "https://", "")}:sub": "system:serviceaccount:kube-system:efs-csi-controller-sa"
          }
        }        
      },
    ]
  })

  tags = {
    tag-key = "efs-csi"
  }
}

# Associate EFS CSI IAM Policy to EFS CSI IAM Role
resource "aws_iam_role_policy_attachment" "efs_csi_iam_role_policy_attach" {
  policy_arn = aws_iam_policy.efs_csi_iam_policy.arn 
  role       = aws_iam_role.efs_csi_iam_role.name
}