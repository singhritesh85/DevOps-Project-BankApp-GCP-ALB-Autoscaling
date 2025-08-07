############################## Create VPC in GCP #######################################

# Create VPC in GCP
resource "google_compute_network" "gcp_vpc" {
  name = "${var.prefix}-vpc"
  auto_create_subnetworks = false   
}

# Create Private Subnet for VPC in GCP
resource "google_compute_subnetwork" "gcp_private_subnet" {
  name = "${var.prefix}-${var.gcp_region}-private-subnet"
  region = var.gcp_region
  network = google_compute_network.gcp_vpc.id 
  private_ip_google_access = true           ### VMs in this Subnet without external IP
  ip_cidr_range = var.ip_range_subnet
}

# Create Public Subnet for VPC in GCP
resource "google_compute_subnetwork" "gcp_public_subnet" {
  name = "${var.prefix}-${var.gcp_region}-public-subnet"
  region = var.gcp_region
  network = google_compute_network.gcp_vpc.id
  private_ip_google_access = false           ### VMs in this Subnet with external IP
  ip_cidr_range = var.ip_public_range_subnet
}

# proxy-only subnet
resource "google_compute_subnetwork" "gcp_proxy_subnet" {
  name          = "bankapp-proxy-subnet"
  ip_cidr_range = var.ip_proxy_range_subnet
  region        = var.gcp_region
  purpose       = "REGIONAL_MANAGED_PROXY"  ### "GLOBAL_MANAGED_PROXY"
  role          = "ACTIVE"
  network       = google_compute_network.gcp_vpc.id
}

######################################################### Firewall Rule for SSH ################################################################

resource "google_compute_firewall" "allow_port_22" {
  name    = "allow-ssh-ingress"
  network = google_compute_network.gcp_vpc.id  # Replace with your VPC network name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["allow-ssh"] # Replace with your desired target tag
}

######################################################### Firewall Rule for HTTPS ################################################################

resource "google_compute_firewall" "allow_port_443" {
  name    = "allow-https-ingress"
  network = google_compute_network.gcp_vpc.id  # Replace with your VPC network name

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["allow-https"] # Replace with your desired target tag
}

######################################################## Firewall Rule to allow health check ######################################################

resource "google_compute_firewall" "allow_health_check" {
  name          = "allow-health-check"
  direction     = "INGRESS"
  network       = google_compute_network.gcp_vpc.id
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]  ### Google uses specific IP ranges for its health check probes.
  allow {
    protocol = "tcp"
  }
  target_tags = ["allow-health-check"]
}

############################## Create VPC in AWS #######################################

resource "aws_vpc" "test_vpc" {
  cidr_block       = "${var.vpc_cidr}"
  instance_tenancy = "default"
  enable_dns_hostnames = true

  tags = {
    Name = "${var.vpc_name}-${var.env}"                     ##"test-vpc"
    Environment = var.env            ##"${terraform.workspace}"
  }
}

############################### Public Subnet in AWS ##########################################

resource "aws_subnet" "public_subnet" {
  count = "${length(data.aws_availability_zones.azs.names)}"
  vpc_id     = "${aws_vpc.test_vpc.id}"
  availability_zone = "${element(data.aws_availability_zones.azs.names,count.index)}"
  cidr_block = "${element(var.public_subnet_cidr,count.index)}"
  map_public_ip_on_launch = true

  tags = {
    Name = "PublicSubnet-${var.env}-${count.index+1}"
    Environment = var.env            ##"${terraform.workspace}"
  }
}

############################### Private Subnet in AWS #########################################

resource "aws_subnet" "private_subnet" {
  count = "${length(data.aws_availability_zones.azs.names)}"                  ##"${length(slice(data.aws_availability_zones.azs.names, 0, 2))}"
  vpc_id     = "${aws_vpc.test_vpc.id}"
  availability_zone = "${element(data.aws_availability_zones.azs.names,count.index)}"
  cidr_block = "${element(var.private_subnet_cidr,count.index)}"

  tags = {
    Name = "PrivateSubnet-${var.env}-${count.index+1}"
    Environment = var.env                ##"${terraform.workspace}"
  }
}

############################### Public Route Table in AWS ####################################

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.test_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.testIGW.id
  }

  tags = {
    Name = "public-route-table-${var.env}"
    Environment = var.env              ##"${terraform.workspace}"
  }
}

resource "aws_route_table_association" "public_route_table_association" {
  count = "${length(data.aws_availability_zones.azs.names)}"
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

############################### Private Route Table in AWS ###################################

resource "aws_default_route_table" "default_route_table" {
  default_route_table_id = aws_vpc.test_vpc.default_route_table_id

   tags = {
    Name = "default-route-table-${var.env}"
    Environment = var.env               ##"${terraform.workspace}"
  }

}

resource "aws_route_table" "private_route_table_1" {
  vpc_id = aws_vpc.test_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gateway.id
}

  tags = {
    Name = "Private-route-table-1-${var.env}"
   Environment = var.env                  ##"${terraform.workspace}"
  }
}

resource "aws_route_table_association" "private_route_table_association_1" {
#  count = "${length(slice(data.aws_availability_zones.azs.names, 0, 2))}"           ##"${length(data.aws_availability_zones.azs.names)}"
  subnet_id      = aws_subnet.private_subnet[0].id                                   ##aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_route_table_1.id
}

resource "aws_route_table" "private_route_table_2" {
  vpc_id = aws_vpc.test_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gateway.id
}

  tags = {
    Name = "Private-route-table-2-${var.env}"
    Environment = var.env                  ##"${terraform.workspace}"
  }
}

resource "aws_route_table_association" "private_route_table_association_2" {
#  count = "${length(slice(data.aws_availability_zones.azs.names, 0, 2))}"        ## "${length(data.aws_availability_zones.azs.names)}"
  subnet_id      = aws_subnet.private_subnet[1].id                             ## aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_route_table_2.id
}

resource "aws_route_table" "private_route_table_3" {
  vpc_id = aws_vpc.test_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gateway.id
}

  tags = {
    Name = "Private-route-table-3-${var.env}"
    Environment = var.env                  ##"${terraform.workspace}"
  }
}

resource "aws_route_table_association" "private_route_table_association_3" {
#  count = "${length(data.aws_availability_zones.azs.names)}"       ##"${length(slice(data.aws_availability_zones.azs.names, 0, 2))}"
  subnet_id      = aws_subnet.private_subnet[2].id         ## aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_route_table_3.id
}

############################################## NAT Gateway in AWS #######################################################

resource "aws_eip" "nat" {
  domain   = "vpc"
  # vpc      = true
}
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnet[0].id
  depends_on    = [aws_internet_gateway.testIGW]

  tags = {
    Name = "${var.natgateway_name}-${var.env}"            ##"NAT_Gateway"
    Environment = var.env          ##"${terraform.workspace}"
  }
}

############################################# Internet Gateway in AWS ####################################################

resource "aws_internet_gateway" "testIGW" {
  vpc_id = aws_vpc.test_vpc.id

  tags = {
    Name = "${var.igw_name}-${var.env}"        #"test-IGW"
    Environment = var.env               ##"${terraform.workspace}"
  }
}
 
############################################ Security Group to Allow All Traffic in AWS #############################

resource "aws_security_group" "all_traffic" {
 name        = "AllTraffic-Security-Group-${var.env}-willnot-be-used"
 description = "Allow All Traffic"
 vpc_id      = aws_vpc.test_vpc.id

ingress {
   description = "Allow All Traffic"
   from_port   = 0
   to_port     = 0
   protocol    = "-1"
   cidr_blocks = ["0.0.0.0/0"]
 }

egress {
   from_port   = 0
   to_port     = 0
   protocol    = "-1"
   cidr_blocks = ["0.0.0.0/0"]
 }
}
