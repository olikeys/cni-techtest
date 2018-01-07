provider "aws" {
  region = "eu-west-1"
}

data "aws_availability_zones" "all" {}

resource "aws_vpc" "management_vpc" {
  cidr_block         = "10.1.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
    tags {
        Name = "managment-vpc"
    }
}

resource "aws_vpc" "application_vpc" {
  cidr_block         = "10.2.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags {
        Name = "application-vpc"
    }
}

resource "aws_internet_gateway" "management_internet_gateway" {
  vpc_id = "${aws_vpc.management_vpc.id}"

    tags {
        Name = "management-vpc-internet-gateway"
  }

}

resource "aws_internet_gateway" "application_internet_gateway" {
  vpc_id = "${aws_vpc.application_vpc.id}"

  tags {
        Name = "application-vpc-internet-gateway"
  }

}

resource "aws_subnet" "management_pub_subnet" {
    count               = "${length(data.aws_availability_zones.all.names)}"
    vpc_id              = "${aws_vpc.management_vpc.id}"
    cidr_block          = "${var.man_pub_subnets[count.index]}"
    availability_zone   = "${data.aws_availability_zones.all.names[count.index]}"

    tags {
    Name = "man-pub-${data.aws_availability_zones.all.names[count.index]}"
  }
}

resource "aws_subnet" "application_pub_subnet" {
    count               = "${length(data.aws_availability_zones.all.names)}"
    vpc_id              = "${aws_vpc.application_vpc.id}"
    cidr_block          = "${var.app_pub_subnets[count.index]}"
    availability_zone   = "${data.aws_availability_zones.all.names[count.index]}"

    tags {
    Name = "app-pub-${data.aws_availability_zones.all.names[count.index]}"
  }
}

resource "aws_subnet" "application_pvt_subnet" {
    count               = "${length(data.aws_availability_zones.all.names)}"
    vpc_id              = "${aws_vpc.application_vpc.id}"
    cidr_block          = "${var.app_pvt_subnets[count.index]}"
    availability_zone   = "${data.aws_availability_zones.all.names[count.index]}"

    tags {
    Name = "app-pvt-${data.aws_availability_zones.all.names[count.index]}"
  }
}

resource "aws_route_table" "management_pub_route" {
  count                    = "${length(data.aws_availability_zones.all.names)}"
  vpc_id                   = "${aws_vpc.management_vpc.id}"

  tags {
    Name = "management-public-subnets-route-table-${data.aws_availability_zones.all.names[count.index]}"
  }
}

resource "aws_route_table" "application_pub_route" {
  count                    = "${length(data.aws_availability_zones.all.names)}"
  vpc_id                   = "${aws_vpc.application_vpc.id}"

  tags {
    Name = "application-public-subnets-route-table-${data.aws_availability_zones.all.names[count.index]}"
  }
}

resource "aws_route_table" "application_pvt_route" {
  count                    = "${length(data.aws_availability_zones.all.names)}"
  vpc_id                   = "${aws_vpc.application_vpc.id}"

    tags {
    Name = "application-private-subnets-route-table-${data.aws_availability_zones.all.names[count.index]}"
  }
}

resource "aws_route_table_association" "management_public" {
    count          = "${length(data.aws_availability_zones.all.names)}"
    subnet_id      = "${element(aws_subnet.management_pub_subnet.*.id, count.index)}"
    route_table_id = "${element(aws_route_table.management_pub_route.*.id, count.index)}"
}



/*
tags                     = "${merge(
                                var.tags,
                                map("Name", "management-private-subnets-route-table-${data.aws_availability_zones.all.names[count.index]}"),
                                map("Description", "Route table for the management private subnet in the ${data.aws_availability_zones.all.names[count.index]} AZ")
                              )}"

module "management_vpc" {
    source      = "./modules/networking/vpc"
    vpc_cidr    = "10.1.0.0/16"

    vpc_name = "management-vpc"
}

module "application_vpc" {
    source      = "./modules/networking/vpc"
    vpc_cidr    = "10.2.0.0/16"

    vpc_name = "application-vpc"
}

*/
