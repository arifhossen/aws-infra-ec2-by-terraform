# EC2 Instance
resource "aws_instance" "main_ec2" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = element(var.subnet_ids, 0)               # Assigning the first public subnet
  vpc_security_group_ids = [var.security_group_id]                  # Use security group IDs instead of names
  user_data              = filebase64("${path.module}/userdata.sh") # User data script for instance initialization
  iam_instance_profile   = var.ec2_iam_profile_name

  # Define the root block device with 50GB disk size
  root_block_device {
    volume_size = 20    # Size in GB
    volume_type = "gp2" # General Purpose SSD
  }

  tags = {
    Name = "${var.organization_name}-${var.project_name}-${var.stage}"
  }

}

# # Application Load Balancer for the student portal
# resource "aws_lb" "main_alb" {
#   name               = "${var.organization_name}-${var.project_name}-lb-${var.stage}" # Load balancer name : only alphanumeric characters and hyphens allowed in "name"
#   internal           = false                                                          # Public load balancer
#   load_balancer_type = "application"                                                  # Type of load balancer
#   security_groups    = [var.security_group_id]                                        # Security group for the load balancer
#   subnets            = var.subnet_ids                                                 # Subnets for the load balancer

#   enable_deletion_protection = false # Deletion protection disabled

#   tags = {
#     Name = "${var.organization_name}_${var.project_name}_lb_${var.stage}" # Tag for the load balancer
#   }
# }

# # Target Group for the ec2
# resource "aws_lb_target_group" "main_tg" {
#   name     = "${var.organization_name}-${var.project_name}-tg-${var.stage}" # Target group name: only alphanumeric characters and hyphens allowed in "name"
#   port     = 80                                                             # Port for traffic
#   protocol = "HTTP"                                                         # Protocol for traffic
#   vpc_id   = var.vpc_id                                                     # VPC ID

#   health_check {
#     path                = "/"               # Health check path
#     protocol            = "HTTP"            # Health check protocol
#     interval            = 30                # Health check interval
#     timeout             = 5                 # Health check timeout
#     healthy_threshold   = 5                 # Number of successful checks before healthy
#     unhealthy_threshold = 2                 # Number of failed checks before unhealthy
#     matcher             = "200,301,302,303" # Expected status codes
#   }

#   tags = {
#     Name = "${var.organization_name}_${var.project_name}_tg_${var.stage}" # Tag for the target group
#   }
# }

# # Attach EC2 instance to Target Group
# resource "aws_lb_target_group_attachment" "main" {
#   target_group_arn = aws_lb_target_group.main_tg.arn
#   target_id        = aws_instance.main_ec2.id
#   port             = 3000
# }

# # HTTP Listener
# resource "aws_lb_listener" "http" {
#   load_balancer_arn = aws_lb.main_alb.arn
#   port              = 80
#   protocol          = "HTTP"

#   default_action {
#     type = "redirect"
#     redirect {
#       port        = "443"
#       protocol    = "HTTPS"
#       status_code = "HTTP_301"
#     }
#   }
# }

# # HTTPS Listener
# resource "aws_lb_listener" "https" {
#   load_balancer_arn = aws_lb.main_alb.arn
#   port              = 443
#   protocol          = "HTTPS"
#   ssl_policy        = "ELBSecurityPolicy-2016-08"
#   # Use the ARN of the existing ACM certificate
#   certificate_arn = var.acm_certificate_arn # Replace with your actual certificate ARN


#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.main_tg.arn
#   }
#   tags = {
#     Name = "${var.organization_name}_${var.project_name}_listener_${var.stage}" # Tag for the listener
#   }
# }


# # Route53 Record for ALB
# resource "aws_route53_record" "alb_record" {
#   zone_id = var.route53_zone_id # Replace with your Route53 Zone ID
#   name    = var.domain_name
#   type    = "A"

#   alias {
#     name                   = aws_lb.main_alb.dns_name
#     zone_id                = aws_lb.main_alb.zone_id
#     evaluate_target_health = true
#   }
# }
