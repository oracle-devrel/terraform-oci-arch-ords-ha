## Copyright © 2022, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

# This Terraform script provisions N compute instances and installs ORDS on each one

# Create Random List of Fault Domains

resource "random_shuffle" "fd" {
  input        = ["FAULT-DOMAIN-1", "FAULT-DOMAIN-2", "FAULT-DOMAIN-3"]
  result_count = var.number_of_midtiers
}


# Create Compute Instance

resource "oci_core_instance" "compute_instance" {
  count               = var.number_of_midtiers
  availability_domain = local.availability_domain_name
  compartment_id      = var.compartment_ocid
  display_name        = "ORDS${count.index}"
  shape               = var.instance_shape
  
  lifecycle {
    ignore_changes = [ defined_tags["Oracle-Tags.CreatedBy"], defined_tags["Oracle-Tags.CreatedOn"] ]
  }
  
  dynamic "shape_config" {
    for_each = local.is_flexible_node_shape ? [1] : []
    content {
      memory_in_gbs = var.instance_flex_shape_memory
      ocpus = var.instance_flex_shape_ocpus
    }
  }

 fault_domain        = "${random_shuffle.fd.result[count.index]}"

  source_details {
    source_type             = "image"
    source_id               = data.oci_core_images.InstanceImageOCID.images[0].id
    boot_volume_size_in_gbs = "50"
  }

  create_vnic_details {
    subnet_id = oci_core_subnet.subnet_2.id
    nsg_ids = [oci_core_network_security_group.WebSecurityGroup.id, oci_core_network_security_group.SSHSecurityGroup.id]
  }

  metadata = {
    ssh_authorized_keys = tls_private_key.key.public_key_openssh
    #user_data = data.template_cloudinit_config.cloud_init.rendered
  }

  defined_tags = {"${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }

  timeouts {
    create = "60m"
  }
}