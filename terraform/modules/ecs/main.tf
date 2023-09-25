################################################################################################################################
# cluster/main.tf
################################################################################################################################

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster https://aws.amazon.com/fargate/
resource "aws_ecs_cluster" "primary" {
  name = "${var.environment_name}-${var.aws_region}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Environment = var.environment_name
    Project     = var.project_name
  }
}

