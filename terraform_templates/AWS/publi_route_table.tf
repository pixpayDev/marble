# --- Public Route Table ---

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "public-rt-public" }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  # Vers yente (VPC Pixpay Prod) via le peering créé par le repo terraform-opensanction
  route {
    cidr_block                = "172.31.0.0/16"
    vpc_peering_connection_id = "pcx-054b841b673563928"
  }
}

resource "aws_route_table_association" "public" {
  count          = local.azs_count
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}