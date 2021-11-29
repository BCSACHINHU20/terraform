resource "google_compute_instance_template" "hu19-bcsachin-template" {
  name         = "hu19-bcsachin-template"
  machine_type = "e2-medium"
  disk {
    source_image = "ubuntu-os-cloud/ubuntu-1804-lts"
    auto_delete  = true
    disk_size_gb = 100
    boot         = true
  }

  network_interface {
    network = "default"
  }
  metadata_startup_script=file(script.sh)

  metadata = {
     "environment" : "HU19"
     "createdby" : "linker-bcsachin"
     "managedby" : "terraform"
  }

  can_ip_forward = true
}

resource "google_compute_instance_from_template" "hu19-bcsachin-template-instance" {
  name = "hu19-bcsachin-template-instance"
  zone = "us-central1-a"

  source_instance_template = google_compute_instance_template.hu19-bcsachin-template.id

  // Override fields from instance template
  can_ip_forward = false
  labels = {
    "createdby" = "linker-bcsachin"
  }
}


resource "google_compute_instance_group_manager" "hu19-bcsachin-rsrc-grp" {
  name = "hu19-bcsachin-rsrc-grp"

  base_instance_name = "hu19-bcsachin-template"
  zone               = "us-central1-a"

  version {
    instance_template  = google_compute_instance_template.hu19-bcsachin-template.id
  }

  named_port {
    name = "customHTTP"
    port = 8888
  }
}