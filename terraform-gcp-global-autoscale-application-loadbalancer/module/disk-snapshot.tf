resource "google_compute_resource_policy" "disk_snapshot_policy" {
  name    = "gitlab-runner-root-disk-snapshot-policy"
  region  = "us-central1"

  snapshot_schedule_policy {
    schedule {
      hourly_schedule {
        hours_in_cycle = 12      ### Snapshots will be created after 12 hours
        start_time = "23:00"     ### Time is in UTC
      }
    }
    retention_policy {
      max_retention_days = 30    ### For one month snapshots will be kept.
      on_source_disk_delete = "KEEP_AUTO_SNAPSHOTS"  ### behavior for scheduled snapshots when the source disk is deleted
    }
    snapshot_properties {
      storage_locations = ["us-central1"]
###   guest_flush       = true  ### Application consistent snapshot will be used for databases and file servers.
    }
  }

}

resource "google_compute_disk_resource_policy_attachment" "snapshot_attachment" {
  name = google_compute_resource_policy.disk_snapshot_policy.name
  zone = google_compute_instance.vm_instance.zone  ### Zone where the disk resides and by default the disk resides in the same zone where vm instance exists.
  disk = google_compute_instance.vm_instance.name  ### Name of the root disk is same as that of GCP VM Instance.
}
