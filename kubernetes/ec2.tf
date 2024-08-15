# configured aws provider with proper credentials
# provider "aws" {
#   region    = "us-east-1"
#   profile   = "yusuf"
# }

# create security group for the ec2 instance
resource "aws_security_group" "ec2_security_group4" {
  name        = "ec2 security group4"
  description = "allow access on ports 8080 and 22"
  vpc_id      = module.myAppp-vpc.vpc_id

  # allow access on port 8080
  ingress {
    description      = "http proxy access"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  # allow access on port 22
  ingress {
    description      = "ssh access"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  } 
  ingress {
    description      = "http access"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "http access"
    from_port        = 8000
    to_port          = 8000
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "mongodb access"
    from_port        = 27017
    to_port          = 27017
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
   ingress {
    description      = "https access"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }


  egress {
    from_port        = 0
    to_port          = 0
    protocol         = -1
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags   = {
    Name = "mongodb server security group"
  }
}


# use data source to get a registered amazon linux 2 ami
data "aws_ami" "ubuntu" {

    most_recent = true

    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
    }

    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }

    owners = ["099720109477"]
}

# launch the ec2 instance
resource "aws_instance" "ec2_instance" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.small"
  subnet_id              = module.myAppp-vpc.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.ec2_security_group4.id]
  key_name               = "devopskeypair"
  #user_data = "${file("install_jenkins.sh")}"

  tags = {
    Name = "mongodb_server"
  }
}

resource "aws_s3_bucket" "resource_name"{
  bucket = "basirat-mongo-db-backup"

  tags = {
    Name = "mongodb1_backup"
  }
}



# print the url of the jenkins server
output "website_url" {
  value     = join("", ["http://", aws_instance.ec2_instance.public_ip])
}