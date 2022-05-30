## Copyright © 2022, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
    }
  }
}

provider "oci" {
  region       = var.region
  tenancy_ocid = var.tenancy_ocid

  #### BEGIN COMMENT OUT FOR USAGE ON ORM AND/OR CLOUD SHELL
  user_ocid   = var.user_ocid
  fingerprint = var.fingerprint
  private_key_path = var.private_key_path
  #private_key_password = var.private_key_password
  #### END COMMENT OUT FOR USAGE ON ORM AND/OR CLOUD SHELL

  disable_auto_retries = "true"
}

provider "oci" {
  alias        = "homeregion"
  region       = data.oci_identity_region_subscriptions.home_region_subscriptions.region_subscriptions[0].region_name
  tenancy_ocid = var.tenancy_ocid

  #### BEGIN COMMENT OUT FOR USAGE ON ORM AND/OR CLOUD SHELL
  user_ocid   = var.user_ocid
  fingerprint = var.fingerprint
  private_key_path = var.private_key_path
  #private_key_password = var.private_key_password
  #### END COMMENT OUT FOR USAGE ON ORM AND/OR CLOUD SHELL

  disable_auto_retries = "true"
}
