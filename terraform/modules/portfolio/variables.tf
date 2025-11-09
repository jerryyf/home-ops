variable "aws_region_lambda" {
  type = string
}

variable "aws_access_key_id_lambda" {
  type = string
}

variable "aws_secret_access_key_lambda" {
  type = string
}

variable "aws_lambda_function_name" {
  type = string
}

variable "bot_token" {
  type = string
}

variable "chat_id" {
  type = string
}

variable "base_url" {
  type = string
}

variable "namespace" {
  type    = string
  default = "prod"
}

variable "tag" {
  type    = string
  default = "1.1.4"
}