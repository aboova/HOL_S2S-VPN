##Public Instance
resource "aws_instance" "public_ec2" {
  ami           = "ami-098e42ae54c764c35"
  instance_type = "t3.micro"
  vpc_security_group_ids = [
    aws_security_group.public-sg.id,
  ]
  subnet_id                     = aws_subnet.public[0].id
  iam_instance_profile          = aws_iam_instance_profile.ec2_profile.name
  associate_public_ip_address = false

  root_block_device {
    volume_size = 10
    volume_type = "gp3"
  }
  key_name = var.ec2_key_name
  tags = {
    Name = format(
      "Public-%s-Server",
      var.environment
    )
  }
  depends_on = [
    aws_iam_role_policy_attachment.EC2RoleforSSM,
  ]
}

##Private Instance
resource "aws_instance" "private_ec2" {
  ami           = "ami-098e42ae54c764c35"
  instance_type = "t3.micro"
  vpc_security_group_ids = [
    aws_security_group.private-sg.id,
  ]
  subnet_id                     = aws_subnet.private[0].id
  iam_instance_profile          = aws_iam_instance_profile.ec2_profile.name
  associate_public_ip_address = false

  root_block_device {
    volume_size = 10
    volume_type = "gp3"
  }
  key_name = var.ec2_key_name
  tags = {
    Name = format(
      "Private-%s-Server",
      var.environment
    )
  }
  depends_on = [
    aws_iam_role_policy_attachment.EC2RoleforSSM,
  ]
}

## EIP 할당
resource "aws_eip" "this" {
  instance = aws_instance.public_ec2.id
  vpc      = true
  tags = {
    Name = format(
      "%s-eip-bastion",
      var.environment
    )
  }
}
