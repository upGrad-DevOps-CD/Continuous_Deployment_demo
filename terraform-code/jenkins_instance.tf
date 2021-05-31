
data "aws_ami" "jenkins_ami" {
  owners = ["self"]
  filter {
    name   = "state"
    values = ["available"]
  }

  filter {
    name   = "tag:Name"
    values = ["jenkins_ami"]
  }

  most_recent = true
}



resource "aws_instance" "JenkinsServer" {
  iam_instance_profile   = aws_iam_instance_profile.jenkins_profile.name
  ami                    = data.aws_ami.jenkins_ami.id
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  instance_type          = "t2.micro"
  tags = merge(local.common_tags,
    { Name = "JenkinsServer" },

  )
  root_block_device {
    volume_type = local.volume_type
    volume_size = local.volume_size
    tags = merge(local.common_tags,
      { Name = "JenkinsServer" },
    )
  }
  key_name = var.ssh_key_name
}

resource "aws_security_group" "jenkins_sg" {
  name = "jenkins_sg"
  ingress {
    description = "open all ports from my public ip"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["${var.user_public_ip}/32"]
  }


  egress {
    description = "Let instances send traffic to any destination"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(local.common_tags,
    { Name = "jenkins_sg" },
  )
}
resource "aws_iam_role" "jenkins_role" {
  name = "jenkins_role"
  assume_role_policy = jsonencode(
    {
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = "ec2.amazonaws.com"
          }
        },
      ]
      Version = "2012-10-17"
    }
  )
  description = "Allows EC2 instances to call AWS services on your behalf."
  tags = merge(local.common_tags,
    { Name = "jenkins_sg" },
  )
}
resource "aws_iam_policy" "ecs_service_update" {
  policy = jsonencode(
          {
               Statement = [
                   {
                       Action   = [
                           "ecs:UpdateService",
                           "ecs:DescribeServices",
                        ]
                       Effect   = "Allow"
                       Resource = "arn:aws:ecs:*:*:service/*"
                       Sid      = "VisualEditor0"
                    },
                   {
                       Action   = "ecs:ListServices"
                       Effect   = "Allow"
                       Resource = "*"
                       Sid      = "VisualEditor1"
                    },
                ]
               Version   = "2012-10-17"
            }
        )
  name = "ecs_service_update_policy"
  tags = merge(local.common_tags,
    { Name = "jenkins_sg" },
  )
}
resource "aws_iam_policy" "ecr_jenkins_update" {
  name = "jenkins_policy_ecr"
  description = "give jenkins access to ecr"
  policy      = jsonencode(
          {
              Statement = [
                  {
                      Action   = "ecr:ListImages"
                      Effect   = "Allow"
                      Resource = "arn:aws:ecr:*:*:repository/*"
                      Sid      = "VisualEditor0"
                    },
                   {
                      Action   = "ecr:GetAuthorizationToken"
                      Effect   = "Allow"
                      Resource = "*"
                      Sid      = "VisualEditor1"
                    },
                  {
                      Action   = [
                           "ecr:GetDownloadUrlForLayer",
                           "ecr:BatchGetImage",
                           "ecr:CompleteLayerUpload",
                           "ecr:DescribeImages",
                           "ecr:DescribeRepositories",
                           "ecr:UploadLayerPart",
                           "ecr:ListImages",
                           "ecr:InitiateLayerUpload",
                           "ecr:BatchCheckLayerAvailability",
                           "ecr:GetRepositoryPolicy",
                           "ecr:PutImage",
                        ]
                       Effect   = "Allow"
                       Resource = "arn:aws:ecr:us-east-1:*"
                       Sid      = "VisualEditor2"
                    },
                ]
              Version   = "2012-10-17"
            }
        )
      tags = merge(local.common_tags,
    { Name = "jenkins_sg" },
  )
    }
  
resource "aws_iam_role_policy_attachment" "ecs_service_update_jenkins_pc" {
  role = aws_iam_role.jenkins_role.name
  policy_arn = "${aws_iam_policy.ecs_service_update.arn}"
}
resource "aws_iam_role_policy_attachment" "ecr_jenkins_update" {
  role = aws_iam_role.jenkins_role.name
  policy_arn = "${aws_iam_policy.ecr_jenkins_update.arn}"
}




resource "aws_iam_instance_profile" "jenkins_profile" {
  role = aws_iam_role.jenkins_role.name
  name = "jenkins_role"
}