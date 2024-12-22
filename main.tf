provider "aws" {
  region = "ap-southeast-1"
}
resource "aws_instance" "my_instance" {
  ami           = "ami-0995922d49dc9a17d" # Use the appropriate AMI ID
  instance_type = "t2.micro"
  key_name      = "ganesh"
  tags = {
  Name = "terraform-instance"
  }
}

resource "aws_autoscaling_group" "asg" {
  desired_capacity     = 2
  max_size             = 3
  min_size             = 1
  vpc_zone_identifier  = ["subnet-0c6a66c55f5e27514"] # Replace with your subnet ID
  #launch_configuration = aws_launch_configuration.lc.id
  launch_template {
    id = aws_launch_template.lt.id
    version = "$Latest"
  }
}

resource "aws_launch_template" "lt" {
  image_id      = "ami-0995922d49dc9a17d"
  instance_type = "t2.micro"
  key_name      = "ganesh"
}

resource "aws_lb" "my_lb" {
  name               = "my-load-balancer"
  internal           = false
  load_balancer_type = "application"
  subnets            = ["subnet-0c6a66c55f5e27514", "subnet-0a49419eea927f4d7"]
}

resource "aws_route53_record" "dns" {
  zone_id = "Z026785324DD30X142ZJ5" # Replace with your Route 53 hosted zone ID
  name    = "samsor_ganesh60.com"
  type    = "A"

  alias {
    name                   = aws_lb.my_lb.dns_name
    zone_id                = aws_lb.my_lb.zone_id
    evaluate_target_health = false
  }
}

