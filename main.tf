provider "aws" {
  region = "us-east-1"
}

# PostgreSQL worker node
resource "aws_instance" "postgresql_worker_node" {
  ami = "ami-0f65671a86f061fcd"
  instance_type = "t2.micro"
  key_name = "my-key-pair"
  security_groups = ["sg-0e5d2c7d68b1b5c61"]

  connection {
    host = self.private_ip
    user = "ec2-user"
    private_key = file("~/.ssh/my-key-pair.pem")
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y docker",
      "sudo systemctl start docker",
      "sudo docker build -t postgresql-image -f dockerfile-postgresql .",
      "sudo docker run -d --name postgresql-container -e POSTGRES_PASSWORD=password -v /var/lib/postgresql/data:/var/lib/postgresql/data -p 5432:5432 postgresql-image",
      "sudo docker login --username AWS --password $(aws ecr get-login-password)",
      "sudo docker tag postgresql-image:latest {aws_account_id}.dkr.ecr.us-east-1.amazonaws.com/postgresql-image:latest",
      "sudo docker push {aws_account_id}.dkr.ecr.us-east-1.amazonaws.com/postgresql-image:latest"
    ]
  }
}

# Nodejs worker node
resource "aws_instance" "nodejs_worker_node" {
  ami = "ami-0f65671a86f061fcd"
  instance_type = "t2.micro"
  key_name = "my-key-pair"
  security_groups = ["sg-0e5d2c7d68b1b5c61"]

  connection {
    host = self.private_ip
    user = "ec2-user"
    private_key = file("~/.ssh/my-key-pair.pem")
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y docker",
      "sudo systemctl start docker",
      "export POSTGRESQL_IP=$(aws ec2 describe-instances --filters 'Name=tag:Name,Values=postgresql_worker_node' --query 'Reservations[*].Instances[*].PrivateIpAddress' --output text)",
      "envsubst < server/.env.template > server/.env",
      "sudo docker build -t nodejs-image -f dockerfile-nodejs .",
      "sudo docker run -d --name nodejs-container -e POSTGRES_PASSWORD=password -p 5000:5000 nodejs-image",
      "sudo docker login --username AWS --password $(aws ecr get-login-password)",
      "sudo docker tag nodejs-image:latest {aws_account_id}.dkr.ecr.us-east-1.amazonaws.com/nodejs-image:latest",
      "sudo docker push {aws_account_id}.dkr.ecr.us-east-1.amazonaws.com/nodejs-image:latest"
    ]
  }
}

# React worker node
resource "aws_instance" "react_worker_node" {
  ami = "ami-0f65671a86f061fcd"
  instance_type = "t2.micro"
  key_name = "my-key-pair"
  security_groups = ["sg-0e5d2c7d68b1b5c61"]

  connection {
    host = self.private_ip
    user = "ec2-user"
    private_key = file("~/.ssh/my-key-pair.pem")
  }

# Nodejs worker node
resource "aws_instance" "nodejs_worker_node" {
  ami = "ami-0f65671a86f061fcd"
  instance_type = "t2.micro"
  key_name = "my-key-pair"
  security_groups = ["sg-0e5d2c7d68b1b5c61"]

  connection {
    host = self.private_ip
    user = "ec2-user"
    private_key = file("~/.ssh/my-key-pair.pem")
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y docker",
      "sudo systemctl start docker",
      "export POSTGRESQL_IP=$(aws ec2 describe-instances --filters 'Name=tag:Name,Values=postgresql_worker_node' --query 'Reservations[*].Instances[*].PrivateIpAddress' --output text)",
      "envsubst < server/.env.template > server/.env",
      "sudo docker build -t nodejs-image -f dockerfile-nodejs .",
      "sudo docker run -d --name nodejs-container -e POSTGRES_PASSWORD=password -p 5000:5000 nodejs-image",
      "sudo docker login --username AWS --password $(aws ecr get-login-password)",
      "sudo docker tag nodejs-image:latest {aws_account_id}.dkr.ecr.us-east-1.amazonaws.com/nodejs-image:latest",
      "sudo docker push {aws_account_id}.dkr.ecr.us-east-1.amazonaws.com/nodejs-image:latest"
    ]
  }
}
