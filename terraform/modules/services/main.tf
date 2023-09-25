################################################################################################################################
# services/main.tf
#
# This file includes...
# - Module configuration blocks for this project's onboarded services
# - Shared IAM role resources
################################################################################################################################

# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
# Services
# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-

module "backend" {
  source = "./ecs-service"

  # input variables
  // project
  aws_region       = var.aws_region
  environment_name = var.environment_name
  project_name     = var.project_name
  // service
  service_name      = "backend"
  service_has_alarm = var.environment_name == "dev" ? false : true # enabled for qa, staging, prod 
  fargate_cpu       = 256                                          # = 0.25 vCPU
  fargate_memory    = 512                                          # = 0.5 GB 
  desired_count     = 5
  app_port          = 8080
  // cluster details
  cluster_arn  = var.cluster_arn
  cluster_name = var.cluster_name
  // iam
  execution_role_arn = aws_iam_role.execution_role.arn # used by ECS cluster for container lifecycle operations
  task_role_arn      = aws_iam_role.task_role.arn      # used by task container
  // vpc
  internet_alb_arn                = var.internet_alb_arn
  internet_alb_sg_id              = var.internet_alb_sg_id
  internet_alb_http_listener_arn  = var.internet_alb_http_listener_arn
  internet_alb_https_listener_arn = var.internet_alb_https_listener_arn
  vpc_id                          = var.vpc_id
  private_subnets                 = var.private_subnets
}

// NOTE: add services here by copying the module block and tweaking input variables as desired

# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
# Shared IAM resources - probably do not update below this flag
# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-

# Create an IAM role that task containers can assume
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
# https://github.com/hashicorp/terraform/issues/5213#issuecomment-186213954 <-- notes on file() function path jazz
resource "aws_iam_role" "task_role" {
  name               = "${var.environment_name}-task_role"
  assume_role_policy = file("${path.module}/policies/task_assume_role_policy.json")
}

# Create an IAM Policy that states the task container's permissions and attach it to task_role
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy
resource "aws_iam_policy" "task_policy" {
  name        = "${var.environment_name}-task_policy"
  description = "Policy for ECS task"
  policy      = file("${path.module}/policies/task_policy.json")
}

resource "aws_iam_role_policy_attachment" "task_role_policy" {
  role       = aws_iam_role.task_role.id
  policy_arn = aws_iam_policy.task_policy.arn
}

# Create an IAM role that the ECS container agent and Docker daemon can assume
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
resource "aws_iam_role" "execution_role" {
  name               = "${var.environment_name}-execution_role"
  assume_role_policy = file("${path.module}/policies/execution_assume_role_policy.json")
}

# Attach the AWS managed AmazonECSTaskExecutionRolePolicy to execution_role
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment
resource "aws_iam_role_policy_attachment" "execution_role" {
  role       = aws_iam_role.execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
