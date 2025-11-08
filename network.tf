# VPC Network for private services
resource "google_compute_network" "main" {
  name                    = "audio-text-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "main" {
  name          = "audio-text-subnet"
  ip_cidr_range = "10.0.0.0/24"
  network       = google_compute_network.main.id
  region        = var.region
}

# VPC Access Connector for Cloud Run to access private services
resource "google_vpc_access_connector" "main" {
  name          = "audio-connector"
  region        = var.region
  ip_cidr_range = "10.8.0.0/28"
  network       = google_compute_network.main.name

  # Scaling configuration
  min_instances = 2
  max_instances = 3
}

# Private IP allocation for Cloud SQL
resource "google_compute_global_address" "private_ip" {
  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.main.id
}

# VPC Peering connection for Cloud SQL
resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.main.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip.name]

  # Ensure the service networking API is enabled before creating connection
  depends_on = [google_compute_global_address.private_ip]

  # Prevent accidental deletion
  deletion_policy = "ABANDON"
}
