resource "google_compute_instance" "hu19-bcsachin-compute-instance" {
  name         = "hu19-bcsachin-compute-instance"
  machine_type = "e2-medium"
  zone         = "us-central1-a"
   deletion_protection =true
  tags = ["environment","HU19","createdby","linker-bcsachin","managedby","terraform"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-1804-lts"
    }
  }

  // Local SSD disk
  scratch_disk {
    interface = "SCSI"
  }

  network_interface {
    network = "default"
    access_config {
      // Ephemeral public IP
    }
  }

  metadata = {
     "environment" : "HU19"
     "createdby" : "linker-bcsachin"
     "managedby" : "terraform"
  }
}