locals {
  public_ip_cidr_range   = "172.30.0.0/18"
  private_ip_cidr_range  = "172.30.64.0/18"
  pod_ip_cidr_range      = "10.224.0.0/14"
  services_ip_cidr_range = "10.240.0.0/20"
  master_ipv4_cidr_range = "172.30.255.240/28"
}
