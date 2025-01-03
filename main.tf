# Main Terraform Configuration for AWS resources.

resource "aws_vpc" "my_vpc" {
  cidr_block = var.cidr
}


resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  availability_zone       = "us-east-1a"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet"
  }

}

resource "aws_subnet" "public_subnet1" {

  vpc_id                  = aws_vpc.my_vpc.id
  availability_zone       = "us-east-1b"
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    name = "internet-gateway"
  }

}


resource "aws_route_table" "route-table" {
  vpc_id = aws_vpc.my_vpc.id

}


resource "aws_route" "route" {
  route_table_id         = aws_route_table.route-table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id

}




resource "aws_route_table_association" "public-subnets_association1" {
  route_table_id = aws_route_table.route-table.id
  subnet_id      = aws_subnet.public_subnet1.id

}


resource "aws_security_group" "sg" {
  name_prefix = "web_sg_"
  vpc_id      = aws_vpc.my_vpc.id

  # Inbound Rule
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  # Outbound rule
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-sg"
  }
}

# Create S3 Bucket
resource "aws_s3_bucket" "nilam-bucket-for-tfproject" {
  bucket = "nilam-bucket-tf-2025"

  tags = {
    Name = "Bucket"
  }
}

# Upload Object in S3 Bucket

#resource "aws_s3_bucket" "name" {

#}

resource "aws_instance" "Webserver-1" {
  ami                    = "ami-0e2c8caa4b6378d8c"
  instance_type          = "t2.micro"
  key_name               = "demo"
  vpc_security_group_ids = [aws_security_group.sg.id]
  subnet_id              = aws_subnet.public_subnet.id
  user_data = base64decode(file("userdata.sh"))
}

resource "aws_instance" "Webserver-2" {
  ami                    = "ami-0e2c8caa4b6378d8c"
  instance_type          = "t2.micro"
  key_name               = "demo"
  vpc_security_group_ids = [aws_security_group.sg.id]
  subnet_id              = aws_subnet.public_subnet1.id
  user_data = base64decode(file("userdata.sh"))
}

resource "aws_lb" "alb" {
  name               = "ALB"
  internal           = false
  load_balancer_type = "application"
  #vpc_id             = aws_vpc.my_vpc.id
  security_groups    = [aws_security_group.sg.id]
  subnets            = [aws_subnet.public_subnet.id, aws_subnet.public_subnet1.id]
}

resource "aws_lb_target_group" "TG" {
  name     = "TG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.my_vpc.id

  health_check {
    path = "/home"
    port = "traffic-port"
  }
}

resource "aws_lb_target_group_attachment" "alb-attch" {
  target_id        = aws_lb_target_group.TG.id
  target_group_arn = aws_lb_target_group.TG.arn
  port             = 80
}

resource "aws_lb_listener" "tg-listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.TG.arn
    type             = "forward"
  }
}

output "LoadbalancerDNS" {
  value = aws_lb.alb.dns_name

}