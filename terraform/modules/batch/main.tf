###################################################################################################################################
# batch/main.tf
###################################################################################################################################

# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
# Jobs
# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-

module "example_job" {
  source = "./job"

  # input variables
  // project
  aws_region       = var.aws_region
  environment_name = var.environment_name
  project_name     = var.project_name
  // job
  job_name      = "example_job"
  job_command   = "./app/batch/run_example_job.sh"
  ecr_root_url  = local.ecr_root_url
  ecr_repo_name = "${var.environment_name}-batch" # when we have >1 jobs, update hard coded "batch"
  // batch env
  batch_compute_env_arn = aws_batch_compute_environment.primary.arn
  batch_role            = aws_iam_role.batch_role.arn
}

# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
# Compute Environment
# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-

resource "aws_batch_compute_environment" "primary" {
  compute_environment_name = "${var.environment_name}-fargate_compute_env"
  type                     = "MANAGED"

  compute_resources {
    type               = "FARGATE"
    max_vcpus          = 256
    security_group_ids = [var.vpc_default_sg]
    subnets            = var.private_subnets
  }
}

# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
# ECR config
# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-

data "aws_caller_identity" "current" {}

locals {
  ecr_root_url = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com"
}

# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
# IAM resources - probably do not update below this flag
# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-

# Create an IAM role that batch resources can assume
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
# https://github.com/hashicorp/terraform/issues/5213#issuecomment-186213954 <-- notes on file() function path jazz
resource "aws_iam_role" "batch_role" {
  name               = "${var.environment_name}-batch_role"
  assume_role_policy = file("${path.module}/policies/batch_assume_role_policy.json")
}

# Create an IAM Policy that states the batch container's permissions and attach it to batch_role
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy
resource "aws_iam_policy" "batch_policy" {
  name        = "${var.environment_name}-batch_policy"
  description = "Policy for Batch containers"
  policy      = file("${path.module}/policies/batch_role_policy.json")
}

resource "aws_iam_role_policy_attachment" "batch_role_policy" {
  role       = aws_iam_role.batch_role.id
  policy_arn = aws_iam_policy.batch_policy.arn
}
