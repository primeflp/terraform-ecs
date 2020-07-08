resource "aws_security_group" "load_balancer_security_group" {
    ingress {
        from_port       = 80
        to_port         = 80
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
    }

    egress {
        from_port       = 80
        to_port         = 80
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "service_security_group" {
    ingress {
        from_port = 0
        to_port   = 0
        protocol  = "-1" #permite traffic in do LB SG
        security_groups = ["${aws_security_group.load_balancer_security_group.id}"]
    }

    egress {
        from_port = 0 # Allowing any incoming port
        to_port   = 0 # Allowing any outgoing port
        protocol  = "-1" # Allowing any outgoing protocol
        cidr_blocks = ["0.0.0.0/0"] # Allowing traffic out to all IP addresses
    }
}
