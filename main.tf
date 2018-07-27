
provider "aws" {
#  access_key = "aws_access_key_id"
#  secret_key = "aws_secret_access_key_id"
  region     = "us-east-1"
}


# Declare the data source
data "aws_availability_zones" "available" {}

data "template_file" "provisioner" {
  #template = "${file("autoscale.conf")}"
  template = "${file("provisioner.sh")}"

  vars {
    dns = ""
    project_name = "${var.project_name}"
    branch = "${var.branch}"
    github_user = "${var.github_user}"
    github_token = "${var.github_token}"
    github_organization = "${var.github_organization}"
    path_to_application = "/${var.project_name}"
  }
}


resource "aws_instance" "web" {
  ami = "ami-759bc50a"
  count = "1"
  key_name = "${var.key_name}"
  vpc_security_group_ids = ["${aws_security_group.instance.id}"]
  instance_type = "t2.micro"
  user_data = "${data.template_file.provisioner.rendered}"
  tags {
    Name = "autoscale_${var.branch}"
  }
}

### Creating Security Group for EC2
resource "aws_security_group" "instance" {
  name = "autoscale_sg"

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ## Creating Launch Configuration
# resource "aws_launch_configuration" "autoscale" {
#   image_id = "ami-759bc50a"
#   instance_type = "t2.micro"
#   security_groups = ["${aws_security_group.instance.id}"]
#   key_name = "${var.key_name}"
#   user_data = <<-EOF
#               #!/bin/bash
#               echo "Hello, World" > index.html
#               nohup busybox httpd -f -p 8080 &
#               EOF
#   lifecycle {
#     create_before_destroy = true
#   }
# }

# ## Creating AutoScaling Group
# resource "aws_autoscaling_group" "autoscale" {
#   launch_configuration = "${aws_launch_configuration.autoscale.id}"
#   availability_zones = ["${data.aws_availability_zones.available.names}"]
#   min_size = 2
#   max_size = 10
#   load_balancers = ["${aws_elb.autoscale.name}"]
#   health_check_type = "ELB"
#   tag {
#     key = "Name"
#     value = "autoscale-asg"
#     propagate_at_launch = true
#   }
# }
#
# ## Security Group for ELB
# resource "aws_security_group" "elb" {
#   name = "autoscale-elb-sg"
#
#   egress {
#     from_port = 0
#     to_port = 0
#     protocol = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#
#   ingress {
#     from_port = 80
#     to_port = 80
#     protocol = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#
#   ingress {
#     from_port = 443
#     to_port = 443
#     protocol = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#
# }
#
# ### Creating ELB
# resource "aws_elb" "autoscale" {
#   name = "autoscale-asg"
#   security_groups = ["${aws_security_group.elb.id}"]
#   availability_zones = ["${data.aws_availability_zones.available.names}"]
#   health_check {
#     healthy_threshold = 2
#     unhealthy_threshold = 2
#     timeout = 3
#     interval = 30
#     target = "HTTP:8080/"
#   }
#   listener {
#     lb_port = 80
#     lb_protocol = "http"
#     instance_port = "8080"
#     instance_protocol = "http"
#   }
# }
