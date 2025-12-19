# ------------------------
# ALB
# ------------------------
resource "aws_lb" "app" {
  name               = "demo-alb"
  load_balancer_type = "application"
  internal           = false
  security_groups    = [aws_security_group.public_alb.id]

  subnets = values(aws_subnet.public)[*].id

  enable_deletion_protection = false

  tags = {
    Name = "demo-alb"
  }
}

resource "aws_lb_target_group" "app" {
  name        = "demo-app-tg"
  port        = 443
  protocol    = "HTTPS"
  vpc_id      = aws_vpc.demo_vpc.id
  target_type = "instance"

  health_check {
    protocol = "HTTPS"
    path     = "/health"
    matcher  = "200"
  }

  tags = {
    Name = "demo-app-tg"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_acm_certificate" "cert" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "alb-cert"
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.app.arn
  port              = 443
  protocol          = "HTTPS"

  ssl_policy      = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn = aws_acm_certificate.cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

resource "aws_lb_target_group_attachment" "app" {
  for_each = aws_instance.demo_ec2

  target_group_arn = aws_lb_target_group.app.arn
  target_id        = each.value.id
  port             = 443
}