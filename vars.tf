# Customizar o nome do cluster
variable "cluster_name" {
    description = "ECS Cluster"
    default     = "cluster-lab"
}

#ECR repositorio
    variable "app_repository_name" {
    description = "my-first-ecr-repo"
    default = "my-first-ecr-repo"
}

# opcoes da aplicacao
variable "container_name" {
    description = "Container app name"
    default     = "micro-api"
}

#Quantos containers
variable "desired_tasks" {
    description = "Number of containers desired to run app task"
    default     = "2"
}

variable "min_tasks" {
    description = "Minimum"
    default     = "1"
}

variable "max_tasks" {
    description = "Maximum"
    default     = "3"
}

variable "cpu_to_scale_up" {
    description = "CPU % to Scale Up the number of containers"
    default    = 80
}

variable "cpu_to_scale_down" {
    description = "CPU % to Scale down the number of containers"
    default	= 20
}

#Desired CPU

variable "desired_task_cpu" {
    description = "Desired CPU to run your tasks"
    default     = "256"
}

#Desired Memory

variable "desired_task_memory" {
    description = "Desired memory to run your tasks"
    default     = "512"
}

# Listener Application Load Balancer Port

variable "alb_port" {
    description = "Origin Application Load Balancer Port"
    default     = "3000"
}

# Target Group Load Balancer Port

variable "container_port" {
    description = "Destination Application Load Balancer Port"
    default     = "3000"
}

#Customize your AWS Region

variable "aws_region" {
    description = "AWS Region for the VPC"
    default     = "us-east-1"
}
