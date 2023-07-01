#This ensures that the role has access to EKS
resource "aws_iam_role" "eks" {
  name = "${var.environment}-${var.customer}-eks"
  path = "/"
 assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
  {
   "Effect": "Allow",
   "Principal": {
    "Service": "eks.amazonaws.com"
   },
   "Action": "sts:AssumeRole"
  }
 ]
}
EOF
}

#Policies allow access EC2 instances with worker nodes and EKS
resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role    = aws_iam_role.eks.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly-EKS" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role    = aws_iam_role.eks.name
}

#Create the EKS cluster
resource "aws_eks_cluster" "eks" {
  depends_on = [aws_iam_role.eks]
  name = "${var.environment}-${var.customer}-cluster"
  role_arn = aws_iam_role.eks.arn
 
  vpc_config {
   subnet_ids = [aws_subnet.subnet_1.id, aws_subnet.subnet_2.id, aws_subnet.subnet_3.id]
  }
}

#IAM role for the worker nodes
resource "aws_iam_role" "nodes" {
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
  role    = aws_iam_role.nodes.name
}
 
resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
 policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
 role    = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "EC2InstanceProfileForImageBuilderECRContainerBuilds" {
 policy_arn = "arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilderECRContainerBuilds"
 role    = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
 policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
 role    = aws_iam_role.nodes.name
}

#Create the worker nodes
resource "aws_eks_node_group" "nodegroup" {
  cluster_name  = aws_eks_cluster.eks.name
  node_group_name = "${var.environment}-${var.customer}-nodes"
  node_role_arn  = aws_iam_role.nodes.arn
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
  ]
}

resource "null_resource" "kubectl_configure" {
  depends_on = [aws_eks_node_group.nodegroup]
  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --region ${var.aws_details.region} --name ${var.environment}-${var.customer}-cluster --profile ${var.environment}-${var.customer}"
    environment = {
      KUBECONFIG = "${var.home}/.kube/${var.environment}-${var.customer}-kubeconfig"
    }
  }
}
