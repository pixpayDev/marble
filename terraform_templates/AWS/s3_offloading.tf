# --- S3 bucket for Marble rule-execution offloading (OFFLOADING_BUCKET_URL) ---

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "offloading" {
  bucket = "marble-offloading-${data.aws_caller_identity.current.account_id}"

  # Chiffrement au repos par défaut
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    Name = "Marble - Offloading - Prod"
  }
}

# Le bucket ne doit jamais être public
resource "aws_s3_bucket_public_access_block" "offloading" {
  bucket                  = aws_s3_bucket.offloading.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Autoriser le rôle de tâche ECS (conteneurs api/cron) à lire/écrire dans le bucket
resource "aws_iam_role_policy" "ecs_task_offloading_s3" {
  name = "marble-offloading-s3-access"
  role = aws_iam_role.ecs_task_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["s3:ListBucket", "s3:GetBucketLocation"],
        Resource = aws_s3_bucket.offloading.arn
      },
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:AbortMultipartUpload"
        ],
        Resource = "${aws_s3_bucket.offloading.arn}/*"
      }
    ]
  })
}
