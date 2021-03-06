provider "aws" {
  region = "us-east-1"
  access_key=""
  secret_key= "" 

}

resource "aws_security_group" "ssh_connection" {
  name = var.sg_name
  dynamic "ingress" { #esto es nuevo
    for_each = var.ingress_rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }
  dynamic "egress" { #esto es nuevo
    for_each = var.egress_rules
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }
  tags = {
    Name = "allow_tls"
  }
}

resource "aws_instance" "instancia-snazarian" {
  ami = var.ami_id
  #ami = "${var.ami_id}" VERSION ANTERIOR TERRAFORM
  instance_type = var.instance_type
  tags          = var.tags
  security_groups = ["${aws_security_group.ssh_connection.name}"]  ##recurso.nombre.lo que espera la variable en este caso name
  # CONEXION
  # provisioner = "remote-exec"{
  #   connection {
  #     type = "ssh"
  #     user = "ec2-user"
  #     private_key="${file(-/.ssh/packer-key)}"
  #     host = self.public_ip
  #   }
  # }

  inline = ["docker run -it -d -p 80:80"]
}

