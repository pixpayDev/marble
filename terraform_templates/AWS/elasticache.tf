# --- ElastiCache Redis (dépendance obligatoire depuis Marble v1.3) ---

resource "aws_elasticache_subnet_group" "marble" {
  name       = "marble-redis-subnet-group"
  subnet_ids = aws_subnet.public[*].id
}

resource "aws_security_group" "redis" {
  name        = "marble-redis-sg"
  description = "Allow Redis (6379) from ECS nodes"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_node_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Marble - Redis - Prod"
  }
}

resource "aws_elasticache_cluster" "marble" {
  cluster_id           = "marble-redis"
  engine               = "redis"
  engine_version       = "7.x"
  node_type            = "cache.t4g.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis7"
  port                 = 6379
  subnet_group_name    = aws_elasticache_subnet_group.marble.name
  security_group_ids   = [aws_security_group.redis.id]

  tags = {
    Name = "Marble - Redis - Prod"
  }
}
