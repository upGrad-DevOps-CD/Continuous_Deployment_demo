resource "aws_ecs_cluster" "cd_demo" {
  name = "cd_demo"
}

resource "aws_ecs_task_definition" "cd_demo_stage" {
  family                   = "cd_demo_stage"
  container_definitions    = <<DEFINITION
  [
    {
      "name": "cd_demo_stage",
      "image": "${aws_ecr_repository.cd_demo_stage.repository_url}",
      "essential": true,
      "portMappings": [
        {
          "containerPort": 5000,
          "hostPort": 5000
        }
      ],
      "memory": 512,
      "cpu": 256
    }
  ]
  DEFINITION
  requires_compatibilities = ["FARGATE"] # Stating that we are using ECS Fargate
  network_mode             = "awsvpc"    # Using awsvpc as our network mode as this is required for Fargate
  memory                   = 512         # Specifying the memory our container requires
  cpu                      = 256         # Specifying the CPU our container requires
  execution_role_arn       = aws_iam_role.cd_demo.arn
}
resource "aws_ecs_task_definition" "cd_demo" {
  family                   = "cd_demo"
  container_definitions    = <<DEFINITION
  [
    {
      "name": "cd_demo",
      "image": "${aws_ecr_repository.cd_demo.repository_url}",
      "essential": true,
      "portMappings": [
        {
          "containerPort": 5000,
          "hostPort": 5000
        }
      ],
      "memory": 512,
      "cpu": 256
    }
  ]
  DEFINITION
  requires_compatibilities = ["FARGATE"] # Stating that we are using ECS Fargate
  network_mode             = "awsvpc"    # Using awsvpc as our network mode as this is required for Fargate
  memory                   = 512         # Specifying the memory our container requires
  cpu                      = 256         # Specifying the CPU our container requires
  execution_role_arn       = aws_iam_role.cd_demo.arn
}

resource "aws_iam_role" "cd_demo" {
  name               = "cd_demo"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "cd_demo" {
  role       = aws_iam_role.cd_demo.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
resource "aws_default_subnet" "ds1a" {
  availability_zone = "us-east-1a"

  tags = {
    Name = "Default subnet for us-east-1a"
  }
}

resource "aws_default_subnet" "ds1b" {
  availability_zone = "us-east-1b"

  tags = {
    Name = "Default subnet for us-east-1b"
  }
}

resource "aws_default_subnet" "ds1c" {
  availability_zone = "us-east-1c"

  tags = {
    Name = "Default subnet for us-east-1c"
  }
}

resource "aws_ecs_service" "cd_demo" {
  name            = "cd_demo"                           # Naming our first service
  cluster         = aws_ecs_cluster.cd_demo.id          # Referencing our created Cluster
  task_definition = aws_ecs_task_definition.cd_demo.arn # Referencing the task our service will spin up
  launch_type     = "FARGATE"
  desired_count   = 1 # Setting the number of containers we want deployed to 3
  load_balancer {
    target_group_arn = aws_lb_target_group.cd_demo.arn # Referencing our target group
    container_name   = aws_ecs_task_definition.cd_demo.family
    container_port   = 5000 # Specifying the container port
  }
  network_configuration {
    subnets          = ["${aws_default_subnet.ds1a.id}", "${aws_default_subnet.ds1b.id}", "${aws_default_subnet.ds1c.id}"]
    assign_public_ip = true # Providing our containers with public IPs
    security_groups  = ["${aws_security_group.cd_demo_ecs_sg.id}"]
  }
}
resource "aws_ecs_service" "cd_demo_stage" {
  name            = "cd_demo_stage"                           # Naming our first service
  cluster         = aws_ecs_cluster.cd_demo.id                # Referencing our created Cluster
  task_definition = aws_ecs_task_definition.cd_demo_stage.arn # Referencing the task our service will spin up
  launch_type     = "FARGATE"
  desired_count   = 1 # Setting the number of containers we want deployed to 3
  load_balancer {
    target_group_arn = aws_lb_target_group.cd_demo_stage.arn # Referencing our target group
    container_name   = aws_ecs_task_definition.cd_demo_stage.family
    container_port   = 5000 # Specifying the container port
  }
  network_configuration {
    subnets          = ["${aws_default_subnet.ds1a.id}", "${aws_default_subnet.ds1b.id}", "${aws_default_subnet.ds1c.id}"]
    assign_public_ip = true # Providing our containers with public IPs
    security_groups  = ["${aws_security_group.cd_demo_ecs_sg.id}"]
  }
}

resource "aws_security_group" "cd_demo_ecs_sg" {
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    # Only allowing traffic in from the load balancer security group
    security_groups = [aws_security_group.cd_demo_lb_sg.id, aws_security_group.cd_demo_lb_stage_sg.id]
  }

  egress {
    from_port   = 0             # Allowing any incoming port
    to_port     = 0             # Allowing any outgoing port
    protocol    = "-1"          # Allowing any outgoing protocol 
    cidr_blocks = ["0.0.0.0/0"] # Allowing traffic out to all IP addresses
  }
}