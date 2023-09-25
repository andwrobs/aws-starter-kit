###################################################################################################################################
# batch/job/main.tf
###################################################################################################################################


# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
# Job Queue
# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-

resource "aws_batch_job_queue" "primary" {
  compute_environments = [var.batch_compute_env_arn]
  name                 = "${var.environment_name}-${var.job_name}-queue"
  priority             = 0
  state                = "ENABLED"
}

# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
# Job Definition
# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-

resource "aws_batch_job_definition" "primary" {
  name                  = "${var.environment_name}-${var.job_name}-def"
  type                  = "container"
  platform_capabilities = ["FARGATE"]

  container_properties = <<CONTAINER_PROPERTIES
  {
    "command": ["${var.job_command}"],
    "image": "${var.ecr_root_url}/${var.ecr_repo_name}:${data.aws_ssm_parameter.primary_image_tag.value}",
    "jobRoleArn": "${var.batch_role}",
    "executionRoleArn": "${var.batch_role}",
    "networkConfiguration": {
      "assignPublicIp": "ENABLED"
    },
    "resourceRequirements": [
      {"type": "VCPU", "value": "8"},
      {"type": "MEMORY", "value": "16384"}
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group" : "/aws/batch/job",
        "awslogs-region" : "us-east-1",
        "awslogs-stream-prefix" : "batch"
      }
    }
  }
  CONTAINER_PROPERTIES
}


# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
# SystemsManager (for image tag)
# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-

resource "aws_ssm_parameter" "primary_image_tag" {
  name  = "${var.environment_name}-batch-image-tag"
  type  = "String"
  value = "INITIAL_TAG_TO_BE_OVERRIDDEN" # default value, will be overridden on first push

  lifecycle {
    ignore_changes = [value] # ensures external updates to `value` are not reverted back to default 
  }
}

data "aws_ssm_parameter" "primary_image_tag" {
  name = aws_ssm_parameter.primary_image_tag.name
}
