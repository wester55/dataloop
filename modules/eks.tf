# Create an IAM role for the EKS cluster
resource "aws_iam_role" "eks_role" {
  name = "${var.environment}-${var.customer}-eks"
  assume_role_policy = jsonencode({
   Statement = [{
    Action = "sts:AssumeRole"
    Effect = "Allow"
    Principal = {
     Service = "eks.amazonaws.com"
    }
   }]
   Version = "2012-10-17"
  })
}

# Attach the EKS policy to the IAM role
resource "aws_iam_role_policy_attachment" "eks_cluster_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly-EKS" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role	     = aws_iam_role.eks_role.name
}

# Create an EKS cluster with the IAM role
resource "aws_eks_cluster" "eks_cluster" {
  name     = "${var.environment}-${var.customer}-cluster"
  depends_on = [aws_iam_role.eks_role]
  role_arn = aws_iam_role.eks_role.arn

  vpc_config {
    subnet_ids = [aws_subnet.subnet_1.id, aws_subnet.subnet_2.id, aws_subnet.subnet_3.id]
  }
}

#IAM role for the worker nodes
resource "aws_iam_role" "nodes_role" {
  name = "${var.environment}-${var.customer}-nodes"
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

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role    = aws_iam_role.nodes_role.name
}
 
resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
 policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
 role    = aws_iam_role.nodes_role.name
}

resource "aws_iam_role_policy_attachment" "EC2InstanceProfileForImageBuilderECRContainerBuilds" {
 policy_arn = "arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilderECRContainerBuilds"
 role    = aws_iam_role.nodes_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
 policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
 role    = aws_iam_role.nodes_role.name
}

#Create the worker nodes
resource "aws_eks_node_group" "nodegroup" {
  cluster_name  = aws_eks_cluster.eks_cluster.name
  node_group_name = "${var.environment}-${var.customer}-nodes"
  node_role_arn  = aws_iam_role.nodes_role.arn
  subnet_ids   = [aws_subnet.subnet_1.id, aws_subnet.subnet_2.id, aws_subnet.subnet_3.id]
  instance_types = ["t3.large"]
 
  scaling_config {
    desired_size = 3
    max_size   = 3
    min_size   = 3
  }
 
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.EC2InstanceProfileForImageBuilderECRContainerBuilds
  ]
}

#Create EBS CSI addon
data "tls_certificate" "eks" {
  url = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "oidc_provider" {
  thumbprint_list = data.tls_certificate.eks.certificates[*].sha1_fingerprint
  url             = data.tls_certificate.eks.url
  client_id_list = ["sts.amazonaws.com"]
}

resource "aws_iam_role" "ebs_csi_driver_role" {
  name = "${var.environment}-${var.customer}-ebs-csi-driver-role"
  assume_role_policy = <<EOF
{
"Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "${aws_iam_openid_connect_provider.oidc_provider.arn}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${replace(aws_iam_openid_connect_provider.oidc_provider.url, "https://", "")}:sub": "system:serviceaccount:kube-system:ebs-csi-controller-sa",
          "${replace(aws_iam_openid_connect_provider.oidc_provider.url, "https://", "")}:aud": "sts.amazonaws.com"
        }
      }
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ebs_csi_driver_policy" {
 policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
 role    = aws_iam_role.ebs_csi_driver_role.name
}

data "aws_caller_identity" "current" {}

resource "null_resource" "eks_add_on" {
  depends_on = [aws_eks_node_group.nodegroup, aws_iam_role_policy_attachment.ebs_csi_driver_policy]
  provisioner "local-exec" {
    command = <<EOF
      # Install aws-ebs-csi-driver add-on
      aws eks create-addon --cluster-name ${var.environment}-${var.customer}-cluster --region ${var.aws_details.region} --profile ${var.environment}-${var.customer} --addon-name aws-ebs-csi-driver --service-account-role-arn arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.environment}-${var.customer}-ebs-csi-driver-role

      # Create manifests related to add-on
      kubectl apply -f ${var.home}/dataloop/modules/manifests/eks/aws-ebs-csi-driver-sc.yaml
    EOF
    # Run the command in the directory where Terraform is executed
    environment = {
      KUBECONFIG = "${var.home}/.kube/${var.environment}-${var.customer}-kubeconfig"
    }
  }
}

resource "null_resource" "kubectl_configure" {
  depends_on = [aws_eks_cluster.eks_cluster]
  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --region ${var.aws_details.region} --name ${var.environment}-${var.customer}-cluster --profile ${var.environment}-${var.customer}"
    environment = {
      KUBECONFIG = "${var.home}/.kube/${var.environment}-${var.customer}-kubeconfig"
    }
  }
}
