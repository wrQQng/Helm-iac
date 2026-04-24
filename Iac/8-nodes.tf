resource "aws_iam_role" "nodes" {
    name = "${local.env}-nodes-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Principal = {
                    Service = "ec2.amazonaws.com"
                }
                Action = "sts:AssumeRole"
            }
        ]
    })

    tags = {
        Name = "${local.env}-nodes-role"
    }
}

resource "aws_iam_role_policy_attachment" "nodes" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "cni" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "registry" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
    role       = aws_iam_role.nodes.name
}

resource "aws_security_group" "eks_nodes" {
  name        = "${local.env}-eks-nodes-sg"
  description = "EKS worker nodes"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



resource "aws_launch_template" "eks_nodes" {
  name_prefix = "${local.env}-eks-nodes-"

  vpc_security_group_ids = [
    aws_security_group.eks_nodes.id,
    aws_eks_cluster.eks.vpc_config[0].cluster_security_group_id
    ]

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${local.env}-eks-node"
    }
  }
}

resource "aws_eks_node_group" "general" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "general"
  version         = local.eks_version
  node_role_arn   = aws_iam_role.nodes.arn

  subnet_ids = [
    aws_subnet.private_zone1.id,
    aws_subnet.private_zone2.id,
  ]

  capacity_type  = "ON_DEMAND"
  instance_types = ["t3.small"]

  launch_template {
    id      = aws_launch_template.eks_nodes.id
    version = aws_launch_template.eks_nodes.latest_version
  }

  scaling_config {
    desired_size = 1
    max_size     = 3
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    role = "general"
  }

  depends_on = [
    aws_iam_role_policy_attachment.nodes,
    aws_iam_role_policy_attachment.cni,
    aws_iam_role_policy_attachment.registry,
  ]

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  tags = {
    Name = "${local.env}-nodes"
  }
}