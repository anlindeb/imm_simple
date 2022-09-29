# =============================================================================
# IAM endpoint Policy
# -----------------------------------------------------------------------------


# This is the base policy, which does not include any users
resource "intersight_iam_end_point_user_policy" "user_policy1" {
  name = "user_policy1"
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

  password_properties {
    enforce_strong_password  = false
    enable_password_expiry   = false
    force_send_password      = true
    password_expiry_duration = 1
    password_history         = 0
    notification_period      = 0
    grace_period             = 0
  }

}

##  Admin user

# This resource is a user that will be added to the policy.
resource "intersight_iam_end_point_user" "admin" {
  name = "admin"
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

# This data source retrieves a system built-in role that we want to assign to the admin user.
data "intersight_iam_end_point_role" "imc_admin" {
  name      = "admin"
  role_type = "endpoint-admin"
  type      = "IMC"
}

# This resource adds the user to the policy using the role we retrieved.
# Notably, the password is set in this resource and NOT in the user resource above.
resource "intersight_iam_end_point_user_role" "admin" {
  dynamic "tags" {
    for_each = var.tags
    content {
      key   = tags.value.key
      value = tags.value.value
    }
  }

  enabled  = true
  password = var.imc_admin_password

  end_point_user {
    moid = intersight_iam_end_point_user.admin.moid
  }

  end_point_user_policy {
    moid = intersight_iam_end_point_user_policy.user_policy1.moid
  }

  end_point_role {
    moid = data.intersight_iam_end_point_role.imc_admin.results[0].moid
  }

}
