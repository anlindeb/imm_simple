terraform {
    required_version = "> 1.0.10"
    required_providers {
        intersight = {
            source = "CiscoDevNet/intersight"
            version = ">=1.0.28"
        }
    }
}

provider "intersight" {
    apikey = "61fdbccf7564612d3301c805/62c484937564612d3122983d/62c4b4147564612d31244144"
    secretkey = var.secretkey
    endpoint = var.endpoint
}

data "intersight_organization_organization" "default" {
    name = "default"
}
# print default org moid
output "org_default_moid" {
    value = data.intersight_organization_organization.default.moid
}

module "intersight_policy_bundle" {
  source = "./tf-intersight-policy-bundle"

  # external sources
  organization    = data.intersight_organization_organization.default.id

  # every policy created will have this prefix in its name
  policy_prefix = "lab"
  description   = "Built by Terraform and Andrew"

  # Fabric Interconnect 6454 config specifics
  server_ports_6454 = [17, 18, 19, 20, 21 ,22]
  port_channel_6454 = [48, 49]
  uplink_vlans_6454 = {
    "vlan-5-Server" : 5,
    "vlan-6-Client" : 6,
    "vlan-7-Infra" : 7,
    
  }
  native_vlans_6454 = {
    "vlan-10-Mgmt" : 10,
  }
  
  fc_port_count_6454 = 4

  imc_access_vlan    = 10
  imc_admin_password = "Cisco123"

  ntp_servers = ["198.18.128.1"]

  dns_preferred = "198.18.133.1"
  dns_alternate = "198.18.133.2"

  ntp_timezone = "America/New_York"

  # starting values for wwnn, wwpn-a/b and mac pools (size 255)
  wwnn-block   = "20:00:00:CA:FE:00:00:01"
  wwpn-a-block = "20:00:00:CA:FE:0A:00:01"
  wwpn-b-block = "20:00:00:CA:FE:0B:00:01"
  mac-block    = "00:CA:FE:AB:00:00"
  uuid-block   = "0000-000000000001"

  tags = [
    { "key" : "Environment", "value" : "USCX" },
    { "key" : "Orchestrator", "value" : "Terraform" }
  ]
}
