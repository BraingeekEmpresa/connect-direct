provider "aws" {
  region = "us-west-2"
}

resource "aws_eks_cluster" "eks_cluster" {
  name     = "eks-culqui-connect-direct"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = ["subnet-06a8f51a98f16cf51", "subnet-06df8b366d1578274", "subnet-097c674a3a517bec2"]
    security_group_ids =  ["sg-0e170ca1f9239244f"]
  }

  version = "1.25" 

  depends_on = [aws_iam_role_policy_attachment.eks_cluster]
}

resource "aws_iam_role" "eks_cluster_role" {
  name = "eks_cluster_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_eks_node_group" "eks_nodes_primary" {
  count = 1
  version = "1.25"
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "eks-nodes"
  node_role_arn   = aws_iam_role.example.arn

  capacity_type = "ON_DEMAND"

    depends_on = [
    aws_iam_role_policy_attachment.example-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.example-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.example-AmazonEC2ContainerRegistryReadOnly,
  ]
  
 scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }
  #remote_access {
  #  ec2_ssh_key = "your-ssh-key-name"
  #}

  subnet_ids = ["subnet-06a8f51a98f16cf51", "subnet-06df8b366d1578274", "subnet-097c674a3a517bec2"]
  instance_types = ["t2.micro"]
}






resource "aws_iam_role" "example" {
  name = "eks-node-group-example"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "example-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.example.name
}

resource "aws_iam_role_policy_attachment" "example-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.example.name
}
resource "aws_iam_role_policy_attachment" "example-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.example.name
}
