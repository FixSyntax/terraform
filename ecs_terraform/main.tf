provider "aws" {
  region = "xxx"
  access_key = "xxx"
  secret_key = "xxx"
}
resource "aws_ecr_repository" "default" {
  name = "rc-teste/teste"
}
/*
// cria o ciclo de vida do repositorio
resource "aws_ecr_lifecycle_policy" "default" {
  repository = "${aws_ecr_repository.default.name}"
  policy     = "${file("templates/default-lifecycle-policy.json")}"
  #policy     = "${var.lifecycle_policy != "" ? var.lifecycle_policy : file("${path.module}/templates/default-lifecycle-policy.json")}"
}
*/

data "aws_ecs_task_definition" "teste-terraform" {
  task_definition = "${aws_ecs_task_definition.teste-terraform.family}"
}
resource "aws_ecs_task_definition" "teste-terraform" {
  family = "teste-terraform"

  container_definitions = <<DEFINITION
[
  {
    "cpu": 128,
    "environment": [{
      "name": "teste"
    }],
    "essential": true,
    "image": "xxx.dkr.ecr.sa-east-1.amazonaws.com/rc-teste/teste:latest",
    "memory": 128,
    "memoryReservation": 64,
    "name": "teste"
  }
]
DEFINITION
}

data "aws_ecs_cluster" "cluster-aaa" {
  cluster_name = "cluster-aaa"
}

// cria o service dentro do cluster
resource "aws_ecs_service" "teste-terraform" {
  name          = "teste-terraform"
  cluster       = "${data.aws_ecs_cluster.cluster-integration.arn}"
  desired_count = 2

  
  # Track the latest ACTIVE revision
  task_definition = <<EOF
 "${aws_ecs_task_definition.teste-terraform.family}:${max("${aws_ecs_task_definition.teste-terraform.revision}", 
 "${data.aws_ecs_task_definition.teste-terraform.revision}")}"
 EOF
 }

/*
// cria o service dentro do cluster
resource "aws_ecs_service" "teste-terraform" {
  task_definition = "${teste-terraform.arn}"
  scheduling_strategy = "REPLICA"
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 100
  deployment_controller = "ECS"

  load_balancer {
    load_balancer_type = "application"
    service_role = "AWSServiceRoleForECS"
    elb_name = "cluster-integration-internal"

    //ver essa parada do target se tem que criar um antes
    //target_group_arn = "${aws_lb_target_group.foo.arn}"
    container_name   = "teste"
    container_port   = 8080
   }
  }
*/