terraform {
  backend "s3" {
    bucket = "game-terraform-state-store"
    key    = "terraform.tfstate"
    region = "eu-west-1"
  }
}
