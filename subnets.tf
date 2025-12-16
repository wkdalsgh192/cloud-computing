resource "aws_subnet" "public" {
    for_each = local.subnets.public

    vpc_id = aws_vpc.demo_vpc.id
    cidr_block = each.value
    availability_zone = each.key
    map_public_ip_on_launch = true

    tags = {
        Name = "public-${each.key}"
        Tier = "public"
    }
}

resource "aws_subnet" "private" {
    for_each = local.subnets.private

    vpc_id = aws_vpc.demo_vpc.id
    cidr_block = each.value
    availability_zone = each.key
    map_public_ip_on_launch = false

    tags = {
        Name = "private-${each.key}"
        Tier = "private"
    }
}