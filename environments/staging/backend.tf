terraform {
  backend "s3" {
    bucket       = "nishad-terraform-state-2026"
    key          = "staging/terraform.tfstate"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true
  }
}
