resource "aws_security_group" "public-sg" {
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
    description = "for SSH access"
  }
  ingress {
    from_port   = 4500
    to_port     = 4500
    protocol    = "UDP"
    cidr_blocks = ["0.0.0.0/0"]
    description = "for Openswan access"
  }
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "ICMP"
    cidr_blocks = ["0.0.0.0/0"]
    description = "for ICMP"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "myself"
  }
  vpc_id = local.vpc_id

  name = format(
    "%s-public-sg",
    var.environment,
  )
  description = format(
    "%s-public-sg",
    var.environment,
  )
  tags = {
    Name = format(
      "%s-public-sg",
      var.environment,
    )
  }
}

resource "aws_security_group" "private-sg" {
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
    description = "for SSH access"
  }
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "ICMP"
    cidr_blocks = ["0.0.0.0/0"]
    description = "for ICMP"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "myself"
  }
  vpc_id = local.vpc_id

  name = format(
    "%s-private-sg",
    var.environment,
  )
  description = format(
    "%s-private-sg",
    var.environment,
  )
  tags = {
    Name = format(
      "%s-private-sg",
      var.environment,
    )
  }
}