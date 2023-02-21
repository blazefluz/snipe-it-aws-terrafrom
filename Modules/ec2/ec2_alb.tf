resource "aws_lb" "bastion-alb" {
  name               = "bastion-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [
    var.security_group_ids.egress,
    var.security_group_ids.http,
    var.security_group_ids.ssh,
  ]

  subnets            = [for subnet in aws_subnet.public : subnet.id]

  tags = var.tags

}

resource "aws_lb_target_group_attachment" "bastion-alb-tg-attach" {
  target_group_arn = aws_lb_target_group.bastion-alb-tg.arn
  target_id        = aws_instance.bastion-intance.id
  port             = 80

  depends_on = [
    aws_lb.bastion-alb.tg
  ]
}


resource "aws_lb_target_group" "bastion-alb-tg" {
  name     = "bastion-alb-tg"
  port     = 80
  protocol = "HTTP"
  target_type = "intance"
  vpc_id   = var.vpc_id

  depends_on = [
    aws_lb.bastion-alb
  ]
   
  tags = var.tags
}

resource "aws_lb_listener" "bastion-alb-listener-https" {
  load_balancer_arn = aws_lb.bastion-alb.arn
  port              = "443"
  protocol          = "HTTPS"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.bastion-alb-tg.arn
  }
}

resource "aws_lb_listener" "bastion-alb-listener-http" {
  load_balancer_arn = aws_lb.bastion-alb.arn
  port              = "80"
  protocol          = "HTTPS"

  certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.bastion-alb-tg.arn
  }
}


