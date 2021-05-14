module "iap_bastion_group" {
  source      = "terraform-google-modules/terraform-google-bastion-host/modules/bastion-group"
  project     = var.project
  region      = var.region
  zone        = var.zone
  network     = var.network
  subnet      = var.subnet
  members     = var.members
  target_size = var.target_size
}



resource "google_compute_firewall" "allow_access_from_bastion" {
  project = var.project
  name    = "allow-bastion-group-ssh"
  network = google_compute_network.network.self_link

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
 # Allow SSH only from IAP Bastion
 source_service_accounts = [module.iap_bastion_group.service_account]
}

