terraform {
  backend "gcs" {
    bucket  = "dolo-dempo"
    prefix  = "global-state/autoscale-alb"
  }
}
