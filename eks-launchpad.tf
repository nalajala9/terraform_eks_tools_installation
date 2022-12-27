terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}
# Configure the AWS instance
resource "aws_instance" "web" {
  ami = "ami-0574da719dca65348" # you can use this too data.aws_ami.my-ami.id
  instance_type = var.instance-type[1]
  associate_public_ip_address=true
  vpc_security_group_ids = [aws_security_group.eks-launchpad-sg.id]
  iam_instance_profile = aws_iam_instance_profile.eks_profile.name
  key_name = "amazonfirst-JavMvnJenTom"  

  tags = {
    Name = "EKS-LaunchPad"
  }
}
resource "null_resource" "configure-consul-ips" {
  # Configure the file provisioner to copy the source file in current directory to remote directory 
  provisioner "file" {
    source      = "install_tools.sh"
    destination = "/tmp/install_tools.sh"
  }
# Configure the remote-exec to run the scripts in remote machine 
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/install_tools.sh",
      "/tmp/install_tools.sh",
    ]
  }

  connection {
    type         = "ssh"
    host         = aws_instance.web.public_ip
    user         = "ubuntu"
    private_key  = file("./amazonfirst-JavMvnJenTom.pem" )
   }
}

data "aws_vpc" "default" {
  default = true
} 

# Configure another resource security groups
resource "aws_security_group" "eks-launchpad-sg" {
  # Name, Description and the VPC of the Security Group
  name = "eks-launchpad-sg"
  description = "Security group for EKS-Launchpad"
  vpc_id = data.aws_vpc.default.id

  # Since we only want to be able to SSH into the Jenkins EC2 instance, we are only
  # allowing traffic from our IP on port 22
  ingress {
    description = "Allow SSH port"
    from_port = "22"
    to_port = "22"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # We want the Jenkins EC2 instance to being able to talk to the internet
  egress {
    description = "Allow all outbound traffic"
    from_port = "0"
    to_port = "0"
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}









