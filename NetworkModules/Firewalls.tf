provider "null" {
  version = "~> 2.1"
}

provider "google" {
  version = "~> 3.45.0"
}

# [Rule Default Deny]
resource "google_compute_firewall" "default-deny" {
  project     = var.project_id 
  name        = "default-deny-rule"
  network     = var.network
  description = "Creates firewall rule targeting tagged instances"

  allow {
    protocol = "tcp"
    ports    = ["80", "8080", "1000-2000"]
  }
  target_tags = ["web"]
}
