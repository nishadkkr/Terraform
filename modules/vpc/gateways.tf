resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.env}-igw"
  }
}

resource "aws_eip" "nat" {
  for_each = toset(local.nat_azs)

  domain = "vpc"

  tags = {
    Name = "${var.env}-nat-eip-${each.key}"
  }
}

resource "aws_nat_gateway" "this" {
  for_each = toset(local.nat_azs)

  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.public[each.key].id # NAT lives in a PUBLIC subnet

  tags = {
    Name = "${var.env}-nat-${each.key}"
  }

  depends_on = [aws_internet_gateway.this]
}