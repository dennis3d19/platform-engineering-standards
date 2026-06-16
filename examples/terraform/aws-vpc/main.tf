resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${local.naming_prefix}-vpc"
  }
}

# Public subnets (direct internet access via IGW)
resource "aws_subnet" "public" {
  count = length(local.network_azs)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = local.network_public_subnets[count.index]
  availability_zone       = local.network_azs[count.index]
  map_public_ip_on_launch = false # Assign EIPs explicitly; don't auto-assign

  tags = {
    Name = "${local.naming_prefix}-public-${local.network_azs[count.index]}"
    Tier = "public"
  }
}

# Private subnets (outbound via NAT Gateway)
resource "aws_subnet" "private" {
  count = length(local.network_azs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = local.network_private_subnets[count.index]
  availability_zone = local.network_azs[count.index]

  tags = {
    Name = "${local.naming_prefix}-private-${local.network_azs[count.index]}"
    Tier = "private"
  }
}

# Database subnets (no outbound internet access)
resource "aws_subnet" "database" {
  count = length(local.network_azs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = local.network_database_subnets[count.index]
  availability_zone = local.network_azs[count.index]

  tags = {
    Name = "${local.naming_prefix}-database-${local.network_azs[count.index]}"
    Tier = "database"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.naming_prefix}-igw"
  }
}

# Elastic IPs for NAT Gateways
resource "aws_eip" "nat" {
  count  = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(local.network_azs)) : 0
  domain = "vpc"

  tags = {
    Name = "${local.naming_prefix}-nat-eip-${count.index}"
  }

  depends_on = [aws_internet_gateway.main]
}

# NAT Gateways (one per AZ in production; single for non-prod cost saving)
resource "aws_nat_gateway" "main" {
  count = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(local.network_azs)) : 0

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name = "${local.naming_prefix}-nat-${count.index}"
  }

  depends_on = [aws_internet_gateway.main]
}

# Route table: public (routes to IGW)
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${local.naming_prefix}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Route tables: private (routes to NAT Gateway)
resource "aws_route_table" "private" {
  count  = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(local.network_azs)) : 1
  vpc_id = aws_vpc.main.id

  dynamic "route" {
    for_each = var.enable_nat_gateway ? [1] : []
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = var.single_nat_gateway ? aws_nat_gateway.main[0].id : aws_nat_gateway.main[count.index].id
    }
  }

  tags = {
    Name = "${local.naming_prefix}-private-rt-${count.index}"
  }
}

resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = var.single_nat_gateway ? aws_route_table.private[0].id : aws_route_table.private[count.index].id
}

# VPC Flow Logs
resource "aws_cloudwatch_log_group" "flow_logs" {
  count = var.enable_flow_logs ? 1 : 0

  name              = "/aws/vpc/${local.naming_prefix}-flow-logs"
  retention_in_days = 30

  tags = {
    Name = "${local.naming_prefix}-flow-logs"
  }
}

resource "aws_iam_role" "flow_logs" {
  count = var.enable_flow_logs ? 1 : 0

  name = "${local.naming_prefix}-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "flow_logs" {
  count = var.enable_flow_logs ? 1 : 0

  name   = "${local.naming_prefix}-flow-logs-policy"
  role   = aws_iam_role.flow_logs[0].id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_flow_log" "main" {
  count = var.enable_flow_logs ? 1 : 0

  vpc_id          = aws_vpc.main.id
  traffic_type    = "ALL"
  iam_role_arn    = aws_iam_role.flow_logs[0].arn
  log_destination = aws_cloudwatch_log_group.flow_logs[0].arn

  tags = {
    Name = "${local.naming_prefix}-flow-log"
  }
}
