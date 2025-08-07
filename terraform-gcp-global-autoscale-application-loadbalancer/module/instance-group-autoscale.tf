resource "google_compute_health_check" "autohealing" {
  name                = "autohealing-health-check"
  check_interval_sec  = 15
  timeout_sec         = 15
  healthy_threshold   = 2
  unhealthy_threshold = 10 # 150 seconds

  http_health_check {
    request_path = "/login"
    port         = "8080"
  }
}

resource "google_compute_region_instance_group_manager" "bankapp_instance_group" {
  name = "${var.prefix}-instance-group"

  base_instance_name         = "${var.prefix}"
  region                     = var.gcp_region
  distribution_policy_zones  = ["us-central1-a", "us-central1-c"]   ### multi-zone

  update_policy {
    type                         = "PROACTIVE"
    instance_redistribution_type = "PROACTIVE"  ### The group attempts to maintain an even distribution of VM instances across zones in the region.
    minimal_action               = "REPLACE"    ### To delete and create new instances.
    max_surge_fixed              = 2            ### should be equal to either 0 or number of zones selected.
  }

  version {
    instance_template = google_compute_instance_template.bankapp_template.id
  }

  all_instances_config {
    metadata = {
      project = var.prefix
    }
    labels = {
      zack = "saviour"
    }
  }

  named_port {
    name = "bankapp-application"
    port = 8080
  }

#  auto_healing_policies {   ### I disable it here otherwise old instances gets deleted as health check fails and new Instances will be created. 
#    health_check      = google_compute_health_check.autohealing.id
#    initial_delay_sec = 300
#  }
}

resource "google_compute_region_autoscaler" "autoscaler" {
  name   = "${var.prefix}-autoscaler"
  region = var.gcp_region
  target = google_compute_region_instance_group_manager.bankapp_instance_group.id

  autoscaling_policy {
    max_replicas    = 6
    min_replicas    = 2
    cooldown_period = 60   ### Number of seconds that the autoscaler should wait before it starts collecting information from a new instance.

    cpu_utilization {
      target = 0.7
    }
  }
}
