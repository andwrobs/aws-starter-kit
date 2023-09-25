###################################################################################################################################
# alb/main.tf
###################################################################################################################################

# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
# ALB
# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-

resource "aws_lb" "internet_alb" {
  name               = "${var.environment_name}-internet-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.internet_alb_sg.id]
  subnets            = var.public_subnets

  enable_deletion_protection = true

  tags = {
    Project     = var.project_name
    Environment = var.environment_name
  }
}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.internet_alb.arn
  port              = 80 # what port to listen on in the ALB
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "The requested URL was not found."
      status_code  = "404"
    }
  }
}

resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.internet_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "NOT_AUTOMATED — REPLACE ME WITH CERT ARN"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "The requested URL was not found."
      status_code  = "404"
    }
  }
}

# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
# Security group
# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-

resource "aws_security_group" "internet_alb_sg" {
  name        = "internet-alb-sg"
  description = "Allow inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }
}
