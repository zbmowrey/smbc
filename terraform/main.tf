# backend

terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "2.25.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"
  default_tags {
    tags = {
      Name = "smbc-with-jay-and-zach"
      Environment = "test"
      Owner = "zach"
      Source = "https://zbmowrey.com/smbc"
      Automation = "terraform"
    }
  }
}

# create a docker provider for terraform
provider "docker" {
  host = "unix:///var/run/docker.sock"
}


# create an ecr repo
resource "aws_ecr_repository" "smbc" {
  name = "smbc"
}

# docker login ecr
resource "null_resource" "smbc-docker-login" {
  provisioner "local-exec" {
    command = "aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin ${aws_ecr_repository.smbc.repository_url}"
  }
}

# create a docker image from dockerfile
resource "docker_image" "smbc" {
  name = aws_ecr_repository.smbc.repository_url
  build {
    context = "../"
  }
}

# docker push image to ecr
resource "null_resource" "smbc-docker-push" {
  depends_on = [docker_image.smbc, null_resource.smbc-docker-login]
  provisioner "local-exec" {
    command = "docker push ${aws_ecr_repository.smbc.repository_url}:latest"
  }
}

resource "aws_iam_role_policy_attachment" "smbc" {
  role       = aws_iam_role.smbc-execution-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}

resource "aws_iam_role" "smbc-execution-role" {
  # used by both lambda and ecs to pull from ecr
  name               = "smbc-execution-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["lambda.amazonaws.com", "ecs.amazonaws.com"]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_lambda_function" "smbc" {
  function_name = "smbc"
  package_type  = "Image"
  role          = aws_iam_role.smbc-execution-role.arn
  image_uri     = "${aws_ecr_repository.smbc.repository_url}:latest"
  depends_on    = [null_resource.smbc-docker-push]
}

# create an ecs cluster named smbc
resource "aws_ecs_cluster" "smbc" {
  name = "smbc"
}

# create an ecs task definition which launches the container
resource "aws_ecs_task_definition" "smbc" {
  family                = "smbc"
  container_definitions = jsonencode([
    {
      name      = "smbc"
      image     = "${aws_ecr_repository.smbc.repository_url}:latest"
      essential = true
      memory    = 512
      cpu       = 256
    }
  ])
  network_mode             = "none"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.smbc-execution-role.arn
  task_role_arn            = aws_iam_role.smbc-execution-role.arn
}

