locals {
  public_subnets = [
    {
      zone    = "${var.region}a"
      cidr    = "10.50.0.0/24"
      zone_id = "az1"
    },
    {
      zone    = "${var.region}c"
      cidr    = "10.50.1.0/24"
      zone_id = "az3"
    }
  ]
  private_subnets = [
    {
      zone    = "${var.region}a"
      cidr    = "10.50.2.0/24"
      zone_id = "az1"
    },
    {
      zone    = "${var.region}c"
      cidr    = "10.50.3.0/24"
      zone_id = "az3"
    }
  ]
  zone_index = {
    "a" = 0,
    "c" = 1
  }
}