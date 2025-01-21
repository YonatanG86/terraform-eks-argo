# modules/gitlab/main.tf
resource "aws_security_group" "gitlab" {
  name_prefix = "${var.project_name}-gitlab-"
  description = "Security group for GitLab server"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_allowed_cidr
  }

  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-gitlab-sg-${var.environment}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_ebs_volume" "gitlab_data" {
  availability_zone = data.aws_subnet.selected.availability_zone
  size              = var.ebs_volume_size
  type              = "gp3"
  iops              = 3000
  throughput        = 125

  encrypted = true

  tags = {
    Name = "${var.project_name}-gitlab-data-${var.environment}"
  }
}

resource "aws_instance" "gitlab" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id

  vpc_security_group_ids = [aws_security_group.gitlab.id]
  key_name               = var.key_name
  iam_instance_profile   = aws_iam_instance_profile.gitlab.name

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  user_data = templatefile("${path.module}/templates/user_data.sh", {
    gitlab_version = var.gitlab_version
  })

  tags = {
    Name = "${var.project_name}-gitlab-${var.environment}"
  }

  depends_on = [aws_ebs_volume.gitlab_data]
}

resource "aws_volume_attachment" "gitlab_data" {
  device_name = "/dev/xvdf"
  volume_id   = aws_ebs_volume.gitlab_data.id
  instance_id = aws_instance.gitlab.id

  skip_destroy = true
}

# IAM Role and Instance Profile
resource "aws_iam_role" "gitlab" {
  name = "${var.project_name}-gitlab-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_instance_profile" "gitlab" {
  name = "${var.project_name}-gitlab-profile-${var.environment}"
  role = aws_iam_role.gitlab.name
}

resource "aws_iam_role_policy_attachment" "ssm_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.gitlab.name
}
