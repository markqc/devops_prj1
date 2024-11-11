provider "aws" {
  region     = "us-east-1"
  access_key = "AKIAUAHP6XOURDP3QTHR"
  secret_key = "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"
}

resource "aws_instance" "jenkins_server" {
  ami           = "ami-0866a3c8686eaeeba" # Amazon Linux 2 / ubuntu 24
  instance_type = "t2.micro"
  key_name      = "myterraform"

  tags = {
    Name = "Jenkins-Server"
  }

  provisioner "remote-exec" {
    inline = [
# Update and install required packages
      "sudo apt update -y",
      "sudo apt upgrade -y",

      # Install Java 17 (required for Jenkins) and fontconfig
      "sudo apt install -y fontconfig openjdk-17-jdk",

      # Download and configure the stable Jenkins repository
      "curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null",

      # Add the Jenkins repository to the package sources
      "echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null",

      # Update package list to include Jenkins and install Jenkins
      "sudo apt update -y",
      "sudo apt install -y jenkins",

      # Start and enable Jenkins service
      "sudo systemctl daemon-reload",
      "sudo systemctl start jenkins",
      "sudo systemctl enable jenkins"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("/home/markmcaneda/terraform-jenkins/myterraform.pem")
      host        = aws_instance.jenkins_server.public_ip
      timeout     = "5m"  # Increase the timeout as needed
    }
  }
}

output "instance_ip" {
  value = aws_instance.jenkins_server.public_ip
}

