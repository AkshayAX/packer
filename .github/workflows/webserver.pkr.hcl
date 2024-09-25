source "amazon-ebs" "webserver" {
  region      = "us-east-1"
  instance_type = "t2.micro"
  ami_name    = "webserver-image-{{timestamp}}"
  source_ami  = "ami-0c55b159cbfafe1f0"  # Base AMI (e.g., Ubuntu 20.04)
  ssh_username = "ubuntu"
}

build {
  sources = ["source.amazon-ebs.webserver"]

  provisioner "shell" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y nginx",
      "sudo systemctl start nginx",
      "sudo systemctl enable nginx",
      # Add more commands to configure MySQL, Redis, etc.
    ]
  }

  provisioner "file" {
    source      = "app_code/"
    destination = "/var/www/html/"
  }

  post-processor "amazon-ami-management" {
    regions = ["us-east-1"]
    ami_tags = {
      Name        = "WebServer-Image"
      Environment = "production"
    }
  }
}
