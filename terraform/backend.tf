terraform {
  backend "s3" {
    encrypt = true
    region  = "eu-west-2"
    bucket  = "cleckheaton-cc-tfstate"
    key     = "cleckheaton-cc"
  }
}
