terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.88"
    }
  }
  cloud { 
    organization = "surprisebuild"
    workspaces { 
      name = "surprisebuild" 
    } 
  } 
  required_version = ">= 1.5.0"
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "example" {
  vpc_id = aws_vpc.example.id
}

resource "aws_route_table" "example" {
  vpc_id = aws_vpc.example.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.example.id
  }
}

resource "aws_route_table_association" "example" {
  count          = 2
  subnet_id      = aws_subnet.example[count.index].id
  route_table_id = aws_route_table.example.id
}

resource "aws_subnet" "example" {
  count = 2
  vpc_id            = aws_vpc.example.id
  cidr_block        = cidrsubnet(aws_vpc.example.cidr_block, 8, count.index)
  availability_zone = element(data.aws_availability_zones.available.names, count.index)
}

data "aws_availability_zones" "available" {}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_cluster" "example" {
  name = "example-cluster"
}

resource "aws_ecs_task_definition" "example" {
  family                   = "example-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "example"
      image     = "public.ecr.aws/d8i0d8d4/surprisebuild/surprisebuildweb:c345b86697918efaa51da5d404b72b39b43d3f37"
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/example"
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "example" {
  name            = "example-service"
  cluster         = aws_ecs_cluster.example.id
  task_definition = aws_ecs_task_definition.example.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = aws_subnet.example[*].id
    security_groups  = [aws_security_group.example.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.example.arn
    container_name   = "example"
    container_port   = 80
  }
}

resource "aws_cloudwatch_log_group" "example" {
  name              = "/ecs/example"
  retention_in_days = 1
}

resource "aws_security_group" "example" {
  name        = "example-sg"
  description = "Allow HTTP traffic"
  vpc_id      = aws_vpc.example.id

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
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "example" {
  name               = "example-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.example.id]
  subnets            = aws_subnet.example[*].id
}

resource "aws_lb_target_group" "example" {
  name     = "example-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.example.id
  target_type = "ip"

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }
}

resource "aws_lb_listener" "example" {
  load_balancer_arn = aws_lb.example.arn
  port              = "443"
  protocol          = "HTTPS"

  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.parent_acm.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.example.arn
  }
}

resource "aws_route53_zone" "example" {
  name = "surprisebuild.com"
}

resource "aws_acm_certificate" "parent_acm" {
  domain_name       = "surprisebuild.com"
  validation_method = "DNS"

  subject_alternative_names = [ "*.surprisebuild.com" ]

  tags = {
    Name = "example-cert"
  }
}

resource "aws_route53_record" "example" {
  zone_id = aws_route53_zone.example.zone_id
  name    = "www.surprisebuild.com"
  type    = "A"

  alias {
    name                   = aws_lb.example.dns_name
    zone_id                = aws_lb.example.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "parent-A" {
  zone_id = aws_route53_zone.example.zone_id
  name    = "surprisebuild.com"
  type    = "A"

  alias {
    name                   = aws_lb.example.dns_name
    zone_id                = aws_lb.example.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "auth-cognito-A" {
  zone_id = aws_route53_zone.example.zone_id
  name    = aws_cognito_user_pool_domain.example.domain
  type    = "A"
  alias {
    evaluate_target_health = false

    name    = aws_cognito_user_pool_domain.example.cloudfront_distribution
    zone_id = aws_cognito_user_pool_domain.example.cloudfront_distribution_zone_id
  }
}

resource "aws_route53_record" "dns-validation" {
  for_each = {
    for dvo in aws_acm_certificate.parent_acm.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.example.zone_id
}

resource "aws_cognito_user_pool" "example" {
  name = "example_user_pool"

  username_attributes = ["email"]
  auto_verified_attributes = ["email"]

  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
    require_uppercase = true
  }

  schema {
    attribute_data_type      = "String"
    name                     = "email"
    required                 = true
    mutable                  = false
    string_attribute_constraints {
      min_length = 1
      max_length = 2048
    }
  }

  verification_message_template {
    default_email_option = "CONFIRM_WITH_LINK"
    email_message_by_link = "Click the link below to verify your email address: {##Verify Email##}"
    email_subject = "Verify your email for SurpriseBuild"
  }
}

resource "aws_cognito_user_pool_client" "example" {
  name         = "example_user_pool_client"
  user_pool_id = aws_cognito_user_pool.example.id
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_scopes                 = ["email", "openid"]
  callback_urls = ["http://localhost:8080/", "https://www.surprisebuild.com/"]
  logout_urls =   ["http://localhost:8080/", "https://www.surprisebuild.com/"]

  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH"
  ]

  supported_identity_providers = ["COGNITO"]
}

resource "aws_cognito_identity_pool" "example" {
  identity_pool_name               = "example_identity_pool"
  allow_unauthenticated_identities = false
  allow_classic_flow               = false

  cognito_identity_providers {
    client_id               = aws_cognito_user_pool_client.example.id
    provider_name           = aws_cognito_user_pool.example.endpoint
    server_side_token_check = true
  }
}

resource "aws_cognito_user_pool_domain" "example" {
  domain      = "authsurprisebuild"
  user_pool_id = aws_cognito_user_pool.example.id
}

resource "aws_s3_bucket" "example" {
  bucket = "surprisebuild-resources-bucket"
}

resource "aws_cloudfront_origin_access_control" "example" {
  name          = "surprisebuild-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "example" {
  origin {
    domain_name = aws_s3_bucket.example.bucket_regional_domain_name
    origin_id   = "S3-${aws_s3_bucket.example.id}"

    origin_access_control_id = aws_cloudfront_origin_access_control.example.id
  }

  enabled             = true
  is_ipv6_enabled     = true

  default_cache_behavior {
    target_origin_id       = "S3-${aws_s3_bucket.example.id}"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US"]
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.parent_acm.arn
    ssl_support_method        = "sni-only"
    minimum_protocol_version  = "TLSv1.2_2021"
  }
}

resource "aws_s3_bucket_policy" "example" {
  bucket = aws_s3_bucket.example.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowCloudFrontAccess"
        Effect    = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.example.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.example.arn
          }
        }
      }
    ]
  })
}