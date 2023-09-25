###################################################################################################################################
# services/_template/main.tf
#
# This file configures the resources needed to run an internet-acccessible ECS service.
###################################################################################################################################

# +-+-+-+-+-+-
# ECR
# +-+-+-+-+-+-

# Image repository
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository
resource "aws_ecr_repository" "primary" {
  name = "${var.environment_name}-${var.service_name}"

  tags = {
    Environment = var.environment_name
    Project     = var.project_name
  }
}

# +-+-+-+-+-+-
# SSM
# +-+-+-+-+-+-

resource "aws_ssm_parameter" "primary_image_tag" {
  name  = "${var.environment_name}-${var.service_name}-image-tag"
  type  = "String"
  value = "INITIAL_TAG_TO_BE_OVERRIDDEN" # default value, will be overridden on first push

  lifecycle {
    ignore_changes = [value] # ensures external updates to `value` are not reverted back to default 
  }
}

data "aws_ssm_parameter" "primary_image_tag" {
  name = aws_ssm_parameter.primary_image_tag.name
}

# +-+-+-+-+-+-
# ECS
# +-+-+-+-+-+-

// Task
// https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition
resource "aws_ecs_task_definition" "primary" {
  family                   = "${var.environment_name}-${var.service_name}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory

  execution_role_arn = var.execution_role_arn # used by ECS cluster for container lifecycle operations
  task_role_arn      = var.task_role_arn      # used by task container

  container_definitions = jsonencode([{
    name      = var.service_name
    image     = "${aws_ecr_repository.primary.repository_url}:${data.aws_ssm_parameter.primary_image_tag.value}"
    essential = true
    portMappings = [{
      hostPort      = var.app_port
      containerPort = var.app_port
      protocol      = "tcp"
    }]

    environment = [
      for key, value in {
        ENVIRONMENT    = var.environment_name
        } : {
        name  = key
        value = value
      }
    ]

    healthCheck = {
      retries = 10
      command = ["CMD-SHELL", "curl -f http://localhost:${var.app_port} || exit 1"]
      timeout : 5
      interval : 10
    }

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.primary_ecs_task.name
        "awslogs-region"        = var.aws_region
        "awslogs-stream-prefix" = "ecs"
      }
    }
  }])
}

# Service
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service
resource "aws_ecs_service" "primary" {
  name            = "${var.environment_name}-${var.service_name}"
  cluster         = var.cluster_arn
  task_definition = aws_ecs_task_definition.primary.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnets
    security_groups  = [aws_security_group.ecs_service_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.http_group.arn
    container_name   = var.service_name
    container_port   = var.app_port
  }

  depends_on = [
    aws_ecs_task_definition.primary
  ]
}

# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
# ALB target group and listener
# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-

resource "aws_lb_target_group" "http_group" {
  name     = "${var.environment_name}-${var.service_name}-tg"
  port     = var.app_port # traffic sent to targets (tasks) on this port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  target_type = "ip"

  lifecycle {
    create_before_destroy = true
  }

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 4
  }
}

resource "aws_lb_listener_rule" "http_listener_rule" {
  listener_arn = var.internet_alb_http_listener_arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.http_group.arn
  }

  condition {
    path_pattern {
      values = ["/${var.service_name}*"]
    }
  }
}

resource "aws_lb_listener_rule" "https_listener_rule" {
  listener_arn = var.internet_alb_https_listener_arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.http_group.arn # SSL terminates at ALB
  }

  condition {
    path_pattern {
      values = ["/${var.service_name}*"]
    }
  }
}


# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
# Security group for ALB<->Services
# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-

resource "aws_security_group" "ecs_service_sg" {
  name        = "${var.environment_name}-${var.service_name}"
  description = "Allow inbound traffic from ALB to ECS Service"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = var.app_port
    to_port         = var.app_port
    protocol        = "tcp"
    security_groups = [var.internet_alb_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Project     = var.project_name
    Environment = var.environment_name
  }
}

# +-+-+-+-+-+-
# CloudWatch
# +-+-+-+-+-+-

# Create a CloudWatch Log
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group
resource "aws_cloudwatch_log_group" "primary_ecs_task" {
  name = "${var.environment_name}-${var.service_name}"

  tags = {
    Project = var.project_name
  }
}

# CloudWatch Metric Alarm
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm
# https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Container-Insights-metrics-ECS.html <- good resource 
resource "aws_cloudwatch_metric_alarm" "task_count_less_than_desired" {
  count = var.service_has_alarm ? 1 : 0

  alarm_name          = "${var.environment_name}-${var.service_name}-task-count"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "RunningTaskCount"
  statistic           = "Minimum"
  period              = 60
  treat_missing_data  = "breaching"
  namespace           = "ECS/ContainerInsights"
  threshold           = var.desired_count
  alarm_description   = "Number of running tasks dropped below desired count."
  alarm_actions       = var.service_has_alarm ? [module.sns-email[0].arn] : []

  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = "${var.environment_name}-${var.service_name}"
  }

  tags = {
    Project     = var.project_name
    Environment = var.environment_name
  }
}

module "sns-email" {
  source = "./../../sns-email"

  # only create an sns topic if the service is marked as needing an alarm
  count = var.service_has_alarm ? 1 : 0

  # who should the alert emails be sent to?
  sns_emails = ["replace.me@google.com"]

  # metadata
  service_name     = var.service_name
  project_name     = var.project_name
  environment_name = var.environment_name
}
