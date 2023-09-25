################################################################################################################################
# sns-email/main.tf
# 
# Note: 
# We use a CloudFormation stack so that we can use the ARN of the SNS alerting topic before it is confirmed via email.
################################################################################################################################

locals {
  formatted_list   = formatlist("{ \"Endpoint\": \"%s\", \"Protocol\": \"%s\"  }", var.sns_emails, var.sns_protocol)
  sns_subscription = join(",", local.formatted_list)
}

# Create an SNS topic w/ email protocol that the CloudWatch Metric Alarm can trigger as an action 
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group
resource "aws_cloudformation_stack" "sns_topic" {
  name = "${var.environment_name}-${var.service_name}-sns-alarm"

  template_body = <<DEFINITION
{
 "AWSTemplateFormatVersion": "2010-09-09",
  "Resources": {
    "EmailSNSTopic": {
      "Type": "AWS::SNS::Topic",
      "Properties": {
        "TopicName": "${var.environment_name}-${var.service_name}-sns-alarm",
        "DisplayName": "${var.environment_name}-${var.service_name}-sns-alarm",
        "Subscription": [
         ${local.sns_subscription}
        ]
      }
    }
  },
  "Outputs" : {
    "ARN" : {
      "Description" : "Email SNS Topic ARN",
      "Value" : { "Ref" : "EmailSNSTopic" }
    }
  }
}
DEFINITION

  tags = {
    Project = var.project_name
  }
}
