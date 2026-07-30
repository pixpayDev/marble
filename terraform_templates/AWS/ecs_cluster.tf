# --- ECS Cluster ---

resource "aws_ecs_cluster" "main" {
  name = "marble-cluster"

  lifecycle {
    # Le cluster réel expose un bloc configuration vide géré par AWS ; éviter le faux diff.
    ignore_changes = [configuration]
  }
}