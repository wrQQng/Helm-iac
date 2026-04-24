# Security Group


resource "aws_security_group" "rds" {
  name        = "${local.env}-rds-sg"
  description = "Allow PostgreSQL access from EKS nodes"
  vpc_id      = aws_vpc.main.id

  ingress {
  description     = "PostgreSQL from EKS cluster nodes"
  from_port       = 5432
  to_port         = 5432
  protocol        = "tcp"
  security_groups = [aws_security_group.eks_nodes.id]
}

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.env}-rds-sg"
  }
}


# Subnet Group — RDS 

resource "aws_db_subnet_group" "rds" {
  name        = "${local.env}-rds-subnet-group"
  description = "RDS subnet group for ${local.env}"
  subnet_ids  = [
    aws_subnet.private_zone1.id,
    aws_subnet.private_zone2.id,
  ]

  tags = {
    Name = "${local.env}-rds-subnet-group"
  }
}


# RDS Instance

resource "aws_db_instance" "postgres" {
  identifier = "${local.env}-postgres"

  engine         = "postgres"
  engine_version = "16.11"
  instance_class = "db.t4g.micro"

  db_name  = "mydb"
  username = "appuser"
  password = "${local.db_password}"

  # Хранилище
  allocated_storage     = 20
  max_allocated_storage = 20 
  storage_type          = "gp3"
  storage_encrypted     = true

  # Сеть
  db_subnet_group_name   = aws_db_subnet_group.rds.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = false

  deletion_protection = false 
  skip_final_snapshot = true 

  tags = {
    Name = "${local.env}-postgres"
  }

  depends_on = [
    aws_db_subnet_group.rds,
    aws_security_group.rds,
  ]
}
