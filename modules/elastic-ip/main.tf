resource "aws_eip" "eip" {
  domain = "vpc"
  tags = {
    Name        = "${var.organization}-${var.project_name}-${var.stage}-eip"
    Environment = "${var.stage}"
    Project     = "${var.project_name}"
  }
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = var.instance_id
  allocation_id = aws_eip.eip.id
}
