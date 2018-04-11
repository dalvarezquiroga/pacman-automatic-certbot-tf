resource "aws_key_pair" "ssh" {
  key_name   = "${var.project_name}_ssh"
  public_key = "${file("keys/id_rsa.pub")}."
}

resource "aws_security_group" "sg_instance" {
  name        = "sg_instance"
  description = "sg_instance"
  vpc_id      = "${aws_vpc.vpc.id}"

ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"
     ]
   }

ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
