variable "aws_region" {
  type = string
}

variable "aws_access_key_id" {
  type      = string
  sensitive = true
}

variable "aws_secret_access_key" {
  type      = string
  sensitive = true
}

variable "aws_region_lambda" {
  type = string
}

variable "aws_access_key_id_lambda" {
  type      = string
  sensitive = true
}

variable "aws_secret_access_key_lambda" {
  type      = string
  sensitive = true
}

variable "aws_lambda_function_name" {
  type = string
}

variable "bot_token" {
  type      = string
  sensitive = true
}

variable "chat_id" {
  type      = string
  sensitive = true
}

variable "nfs_server" {
  type = string
}

variable "nfs_share" {
  type = string
}

variable "base_url_private" {
  type      = string
  sensitive = true
}

variable "base_url_public" {
  type = string
}

variable "base_url_portfolio" {
  type = string
}
