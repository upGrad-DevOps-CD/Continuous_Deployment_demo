resource "aws_alb" "cd-demo" {
  name               = "cd-demo" # Naming our load balancer
  load_balancer_type = "application"
  subnets = [ # Referencing the default subnets
    "${aws_default_subnet.ds1a.id}",
    "${aws_default_subnet.ds1b.id}",
    "${aws_default_subnet.ds1c.id}"
  ]
  # Referencing the security group
  security_groups = ["${aws_security_group.cd_demo_lb_sg.id}"]
}

# Creating a security group for the load balancer:
resource "aws_security_group" "cd_demo_lb_sg" {
  ingress {
    from_port   = 80 # Allowing traffic in from port 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allowing traffic in from all sources
  }

  egress {
    from_port   = 0             # Allowing any incoming port
    to_port     = 0             # Allowing any outgoing port
    protocol    = "-1"          # Allowing any outgoing protocol 
    cidr_blocks = ["0.0.0.0/0"] # Allowing traffic out to all IP addresses
  }
}
resource "aws_alb" "cd-demo-stage" {
  name               = "cd-demo-stage" # Naming our load balancer
  load_balancer_type = "application"
  subnets = [ # Referencing the default subnets
    "${aws_default_subnet.ds1a.id}",
    "${aws_default_subnet.ds1b.id}",
    "${aws_default_subnet.ds1c.id}"
  ]
  # Referencing the security group
  security_groups = ["${aws_security_group.cd_demo_lb_stage_sg.id}"]
}

# Creating a security group for the load balancer:
resource "aws_security_group" "cd_demo_lb_stage_sg" {
  ingress {
    from_port   = 80 # Allowing traffic in from port 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allowing traffic in from all sources
  }

  egress {
    from_port   = 0             # Allowing any incoming port
    to_port     = 0             # Allowing any outgoing port
    protocol    = "-1"          # Allowing any outgoing protocol 
    cidr_blocks = ["0.0.0.0/0"] # Allowing traffic out to all IP addresses
  }
}
resource "aws_default_vpc" "default_vpc" {

}
resource "aws_lb_target_group" "cd_demo" {
  name        = "cddemo"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_default_vpc.default_vpc.id # Referencing the default VPC
  health_check {
    matcher = "200,301,302"
    path    = "/"
  }
}

resource "aws_lb_listener" "cd_demo" {
  load_balancer_arn = aws_alb.cd-demo.arn # Referencing our load balancer
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.cd_demo.arn # Referencing our tagrte group
  }
}

resource "aws_lb_target_group" "cd_demo_stage" {
  name        = "cddemostage"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_default_vpc.default_vpc.id # Referencing the default VPC
  health_check {
    matcher = "200,301,302"
    path    = "/"
  }
}

resource "aws_lb_listener" "cd_demo_stage" {
  load_balancer_arn = aws_alb.cd-demo-stage.arn # Referencing our load balancer
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.cd_demo_stage.arn # Referencing our tagrte group
  }
}