provider "consul" {
    address = "demo.consul.io:80"
    datacenter = "nyc3"
}

resource "consul_keys" "input" {
    key {
        name = "master_ip"
        path = "weave_jmeter_gdh/serverip"
    }
    key {
        name = "subnet_id"
        path = "weave_jmeter_gdh/subnet_id"
    }
}

provider "aws" {
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    region     = "${var.aws_region}"
}

resource "aws_instance" "server" {
    ami                         = "${lookup(var.aws_amis, var.aws_region)}"
    instance_type               = "t2.micro"
    user_data                   = "#!/bin/bash\n\nMASTERIP=${consul_keys.input.var.master_ip}\n${file("user_data_server.txt")}"
    key_name                    = "${var.aws_keypair}"
    security_groups             = ["${aws_security_group.server_in.id}"]
    subnet_id                   = "${aws_subnet.main.id}"
    associate_public_ip_address = true

    count                       = "${lookup(var.instance_count, var.aws_region)}"
}

resource "aws_security_group" "server_in" {
  name = "server_in"
  description = "Allow ports necessary for a server worker instance"
  vpc_id = "${aws_vpc.main.id}"

  ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["${var.control_cidr}"]
  }
  ingress {
      from_port = 6783
      to_port = 6783
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
      from_port = 6783
      to_port = 6783
      protocol = "udp"
      cidr_blocks = ["0.0.0.0/0"]
  }
}
