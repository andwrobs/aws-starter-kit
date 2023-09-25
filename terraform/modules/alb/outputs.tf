###################################################################################################################################
# alb/outputs.tf
###################################################################################################################################

output "internet_alb_arn" {
  description = "The ARN of the ALB"
  value       = aws_lb.internet_alb.arn
}

output "internet_alb_sg_id" {
  description = "The ID of the security group for the internet facing ALB"
  value       = aws_security_group.internet_alb_sg.id
}

output "internet_alb_http_listener_arn" {
  description = "The ARN of the HTTP listener on the internet-facing ALB"
  value       = aws_lb_listener.http_listener.arn
}

output "internet_alb_https_listener_arn" {
  description = "The ARN of the HTTPS listener on the internet-facing ALB"
  value       = aws_lb_listener.https_listener.arn
}
