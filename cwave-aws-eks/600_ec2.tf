# TLS 프라이빗 키 생성 (공개 키 포함)
resource "tls_private_key" "example" {
    algorithm = "RSA"
    rsa_bits  = 2048
}

# AWS에서 키 페어 생성
resource "aws_key_pair" "ec2_key" {
    key_name   = "ec2-key" # AWS에서 사용할 키 페어 이름
    public_key = tls_private_key.example.public_key_openssh
}

# EC2 인스턴스 생성
resource "aws_instance" "nginx_instance" {
    ami             = "ami-08b09b6acd8d62254" # Amazon Linux 2 AMI (리전별로 AMI ID가 다를 수 있음)
    instance_type   = "t2.micro"
    key_name        = aws_key_pair.ec2_key.key_name # AWS에서 생성한 SSH 키 적용
    security_groups = [aws_security_group.nginx_sg.name]

    # 인스턴스를 다시 만들때 빠르게 교체 하기 위한 옵션
    # 미리 살려놓고 죽인다음 교체
    lifecycle {
        create_before_destroy = true
    }

    # user_data(아래 있는 거) 변경시에 자동으로 인스턴스 재생성 옵션
    user_data_replace_on_change = true

    # EC2 시작 시 Nginx 설치 및 실행을 위한 User Data
    user_data = <<-EOF
                #!/bin/bash
                yum update -y
                amazon-linux-extras install nginx1 -y
                systemctl start nginx
                systemctl enable nginx
                EOF
    tags = {
      Name = "nginx-server"
      Environment = "Production"
    }
}


# 출력: EC2 인스턴스의 퍼블릭 IP 주소
output "nginx_instance_public_ip" {
    value       = aws_instance.nginx_instance.public_ip
    description = "Public IP of the Nginx EC2 instance"
}

# 출력: SSH 접속에 사용할 Private Key
output "ssh_private_key_pem" {
    value       = tls_private_key.example.private_key_pem
    description = "Private key for SSH access"
    sensitive   = true
}