provider "aws" {
  version = "~> 2.0"
  region  = "us-east-1" # Setar a regiao aqui
}

resource "aws_ecr_repository" "my_first_ecr_repo" {
  name = "my-first-ecr-repo" #nome do repo
}

resource "aws_ecs_cluster" "cluster-lab" {
  name = "cluster-lab"
}

resource "aws_ecs_task_definition" "my_first_task" {
  family                   = "my-first-task" # Naming our first task
  container_definitions    = <<DEFINITION
  [
    {
      "name": "my-first-task",
      "image": "${aws_ecr_repository.my_first_ecr_repo.repository_url}",
      "essential": true,
      "portMappings": [
        {
          "containerPort": 3000,
          "hostPort": 3000
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
  execution_role_arn      = "${aws_iam_role.ecsTaskExecutionRole.arn}"
}

resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "ecsTaskExecutionRole1"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role_policy.json}"
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

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = "${aws_iam_role.ecsTaskExecutionRole.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_service" "my_first_service" {
    name            = "my_first_service"
    cluster         = "${aws_ecs_cluster.cluster-lab.id}"
    task_definition = "${aws_ecs_task_definition.my_first_task.arn}"
    launch_type     = "FARGATE"
    desired_count   = 3 #numero de containers que queremos efetuar o deploy

    load_balancer {
      target_group_arn = "${aws_lb_target_group.target_group.arn}"
      container_name   = "${aws_ecs_task_definition.my_first_task.family}"
      container_port   = 3000
    }

    network_configuration {
      subnets           = ["${aws_default_subnet.default_subnet_a.id}", "${aws_default_subnet.default_subnet_b.id}", "${aws_default_subnet.default_subnet_c.id}"]
      assign_public_ip  = true #containers terao ip publico
      
    }
}

resource "aws_default_vpc" "default_vpc" {

}

resource "aws_default_subnet" "default_subnet_a" {
  availability_zone = "us-east-1c"
}

resource "aws_default_subnet" "default_subnet_b" {
  availability_zone = "us-east-1f"
}

resource "aws_default_subnet" "default_subnet_c" {
  availability_zone = "us-east-1e"
}

resource "aws_alb" "application_load_balancer" {
  name                = "lb-lab"
  load_balancer_type  = "application"
  subnets   = [
    "${aws_default_subnet.default_subnet_a.id}",
    "${aws_default_subnet.default_subnet_b.id}",
    "${aws_default_subnet.default_subnet_c.id}"
  ]

  security_groups = ["${aws_security_group.load_balancer_security_group.id}"]
}

resource "aws_lb_target_group" "target_group" {
  name        = "target-group"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = "${aws_default_vpc.default_vpc.id}"
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = "${aws_alb.application_load_balancer.arn}"
  port              = "80"
  protocol          = "HTTP"
  default_action  {
    type          = "forward"
    target_group_arn = "${aws_lb_target_group.target_group.arn}"
  }
}
