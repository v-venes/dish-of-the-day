variable "aws_access_key" {
  type = string
}

variable "aws_secret_key" {
  type = string
}

variable "project_name" {
  type    = string
  default = "dish-of-the-day"
}

variable "tags" {
  type = map(string)
  default = {
    Environment = "Production"
    Project     = "dish-of-the-day"
  }
}
