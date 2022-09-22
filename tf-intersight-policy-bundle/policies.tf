# This file creates the following policies:
#    - boot order
#    - ntp
#    - network connectivity (dns)
#    - multicast
#    - Virtual KVM (enable KVM)
#    - Virtual Media
#    - System QoS
#    - IMC Access

# =============================================================================
# Boot Precision (boot order) Policy
# -----------------------------------------------------------------------------

resource "intersight_boot_precision_policy" "boot_precision1" {
  name                     = "${var.policy_prefix}-boot-order"
  description              = var.description
  configured_boot_mode     = "Uefi"
  enforce_uefi_secure_boot = false
  boot_devices {
    enabled     = true
    name        = "KVM_DVD"
    object_type = "boot.VirtualMedia"
    additional_properties = jsonencode({
      Subtype = "kvm-mapped-dvd"
    })
  }
  boot_devices {
    enabled     = true
    name        = "IMC_DVD"
    object_type = "boot.VirtualMedia"
    additional_properties = jsonencode({
      Subtype = "cimc-mapped-dvd"
    })
  }
  boot_devices {
    enabled     = true
    name        = "LocalDisk"
    object_type = "boot.LocalDisk"
    additional_properties = jsonencode({
      Slot = "MSTOR-RAID"
      Bootloader = {
        Description = ""
        Name        = ""
        ObjectType  = "boot.Bootloader"
        Path        = ""
      }
  }
  organization {
    moid        = var.organization
    object_type = "organization.Organization"
  }
  dynamic "tags" {
    for_each = var.tags
    content {
      key   = tags.value.key
      value = tags.value.value
    }
  }
}


# =============================================================================
# Device Connector Policy (optional)
# -----------------------------------------------------------------------------
#
#resource "intersight_deviceconnector_policy" "dc1" {
#  description     = var.description
#  lockout_enabled = true
#  name            = "${var.policy_prefix}-device-connector"
#  organization {
#    moid        = var.organization
#    object_type = "organization.Organization"
#  }
#  dynamic "tags" {
#    for_each = var.tags
#    content {
#      key   = tags.value.key
#      value = tags.value.value
#    }
#  }
#}


# =============================================================================
# NTP Policy
# -----------------------------------------------------------------------------

resource "intersight_ntp_policy" "ntp1" {
  description = var.description
  enabled     = true
  name        = "${var.policy_prefix}-ntp"
  timezone    = var.ntp_timezone
  ntp_servers = var.ntp_servers
  organization {
    moid        = var.organization
    object_type = "organization.Organization"
  }
  # assign this policy to the domain profile being created
  profiles {
    moid        = intersight_fabric_switch_profile.fabric_switch_profile_a.moid
    object_type = "fabric.SwitchProfile"
  }
  profiles {
    moid        = intersight_fabric_switch_profile.fabric_switch_profile_b.moid
    object_type = "fabric.SwitchProfile"
  }
  dynamic "tags" {
    for_each = var.tags
    content {
      key   = tags.value.key
      value = tags.value.value
    }
  }
}


# =============================================================================
# IPMI over LAN (optional)
# -----------------------------------------------------------------------------
#
#resource "intersight_ipmioverlan_policy" "ipmi2" {
#  description = var.description
#  enabled     = false
#  name        = "${var.policy_prefix}-ipmi-disabled"
#  organization {
#    moid        = var.organization
#    object_type = "organization.Organization"
#  }
#  dynamic "tags" {
#    for_each = var.tags
#    content {
#      key   = tags.value.key
#      value = tags.value.value
#    }
#  }
#}


# =============================================================================
# Network Connectivity (DNS)
# -----------------------------------------------------------------------------

# IPv6 is enabled because this is the only way that the provider allows the
# IPv6 DNS servers (primary and alternate) to be set to something. If it is not
# set to something other than null in this resource, then terraform "apply"
# will detect that thare changes to apply every time ("::" -> null).

resource "intersight_networkconfig_policy" "connectivity1" {
  alternate_ipv4dns_server = var.dns_alternate
  preferred_ipv4dns_server = var.dns_preferred
  description              = var.description
  enable_dynamic_dns       = false
  enable_ipv4dns_from_dhcp = false
  enable_ipv6              = false
  enable_ipv6dns_from_dhcp = false
  name                     = "${var.policy_prefix}-dns"
  organization {
    moid        = var.organization
    object_type = "organization.Organization"
  }
  # assign this policy to the domain profile being created
  profiles {
    moid        = intersight_fabric_switch_profile.fabric_switch_profile_a.moid
    object_type = "fabric.SwitchProfile"
  }
  profiles {
    moid        = intersight_fabric_switch_profile.fabric_switch_profile_b.moid
    object_type = "fabric.SwitchProfile"
  }
  dynamic "tags" {
    for_each = var.tags
    content {
      key   = tags.value.key
      value = tags.value.value
    }
  }
}

# =============================================================================
# Multicast
# -----------------------------------------------------------------------------

resource "intersight_fabric_multicast_policy" "fabric_multicast_policy1" {
  name               = "${var.policy_prefix}-multicast"
  description        = var.description
  querier_ip_address = ""
  querier_state      = "Disabled"
  snooping_state     = "Enabled"
  organization {
    moid        = var.organization
    object_type = "organization.Organization"
  }
  dynamic "tags" {
    for_each = var.tags
    content {
      key   = tags.value.key
      value = tags.value.value
    }
  }
}


# =============================================================================
# Virtual KVM Policy
# -----------------------------------------------------------------------------

resource "intersight_kvm_policy" "kvmpolicy1" {
  name                      = "${var.policy_prefix}-kvm-enabled"
  description               = var.description
  enable_local_server_video = true
  enable_video_encryption   = true
  enabled                   = true
  maximum_sessions          = 4
  organization {
    moid = var.organization
  }
  remote_port = 2068
  dynamic "tags" {
    for_each = var.tags
    content {
      key   = tags.value.key
      value = tags.value.value
    }
  }
}


# =============================================================================
# Virtual Media Policy
# -----------------------------------------------------------------------------



resource "intersight_vmedia_policy" "vmedia2" {
  name          = "${var.policy_prefix}-vmedia-enabled"
  description   = var.description
  enabled       = true
  encryption    = true
  low_power_usb = true
  organization {
    moid        = var.organization
    object_type = "organization.Organization"
  }
  dynamic "tags" {
    for_each = var.tags
    content {
      key   = tags.value.key
      value = tags.value.value
    }
  }
}

# =============================================================================
# System Qos Policy
# -----------------------------------------------------------------------------

# this will create the default System QoS policy with zero customization
resource "intersight_fabric_system_qos_policy" "qos1" {
  name        = "${var.policy_prefix}-system-qos"
  description = var.description
  classes {
    best_effort_admin_state        = "Enabled"
    best_effort_bandwidth          = 5
    best_effort_mtu                = 9216
    best_effort_multicast_optimize = false
    best_effort_weight             = 1
    bronze_admin_state             = "Enabled"
    bronze_bandwidth               = 5
    bronze_cos                     = 1
    bronze_mtu                     = 9216
    bronze_multicast_optimize      = false
    bronze_packet_drop             = true
    bronze_weight                  = 1
    description                    = ""
    fc_bandwidth                   = 39
    fc_weight                      = 6
    gold_admin_state               = "Enabled"
    gold_bandwidth                 = 23
    gold_cos                       = 4
    gold_mtu                       = 9216
    gold_multicast_optimize        = false
    gold_packet_drop               = true
    gold_weight                    = 4  
    platinum_admin_state           = "Enabled"
    platinum_bandwidth             = 23
    platinum_cos                   = 5
    platinum_mtu                   = 9216
    platinum_multicast_optimize    = false
    platinum_packet_drop           = false
    platinum_weight                = 4
    silver_admin_state             = "Enabled"
    silver_bandwidth               = 5
    silver_cos                     = 2
    silver_mtu                     = 9216
    silver_multicast_optimize      = false
    silver_packet_drop             = true
    silver_weight                  = 1
  }


  organization {
    moid        = var.organization
    object_type = "organization.Organization"
  }
  # assign this policy to the domain profile being created
  profiles {
    moid        = intersight_fabric_switch_profile.fabric_switch_profile_a.moid
    object_type = "fabric.SwitchProfile"
  }
  profiles {
    moid        = intersight_fabric_switch_profile.fabric_switch_profile_b.moid
    object_type = "fabric.SwitchProfile"
  }
  dynamic "tags" {
    for_each = var.tags
    content {
      key   = tags.value.key
      value = tags.value.value
    }
  }
}

# =============================================================================
# IMC Access
# -----------------------------------------------------------------------------

resource "intersight_access_policy" "access1" {
  name        = "${var.policy_prefix}-imc-access"
  description = var.description
  inband_vlan = var.imc_access_vlan
  inband_ip_pool {
    object_type = "ippool.Pool"
    #Pick one of the 2 next lines depending if you want to hard code the IMC IP Pool
    #moid        = var.imc_access_pool
    moid        = intersight_ippool_pool.ippool_pool1.moid
  }
  organization {
    moid        = var.organization
    object_type = "organization.Organization"
  }
  dynamic "tags" {
    for_each = var.tags
    content {
      key   = tags.value.key
      value = tags.value.value
    }
  }
}

# =============================================================================
# Serial Over LAN (optional)
# -----------------------------------------------------------------------------
#
#resource "intersight_sol_policy" "sol1" {
#  name        = "${var.policy_prefix}-sol-off"
#  description = var.description
#  enabled     = false
#  baud_rate   = 9600
#  com_port    = "com1"
#  ssh_port    = 1096
#  organization {
#    moid        = var.organization
#    object_type = "organization.Organization"
#  }
#  dynamic "tags" {
#    for_each = var.tags
#    content {
#      key   = tags.value.key
#      value = tags.value.value
#    }
#  }
#}
# =============================================================================
# SNMP
# -----------------------------------------------------------------------------

resource "intersight_snmp_policy" "snmp_disabled" {
  name        = "${var.policy_prefix}-snmp-disabled"
  description = var.description
  enabled     = false
  organization {
    moid        = var.organization
    object_type = "organization.Organization"
  }
  dynamic "tags" {
    for_each = var.tags
    content {
      key   = tags.value.key
      value = tags.value.value
    }
  }
}