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

variable "nfs_share_encrypted" {
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

output "aws_access_key_id_lambda" {
  value     = var.aws_access_key_id_lambda
  sensitive = true
}

output "aws_secret_access_key_lambda" {
  value     = var.aws_secret_access_key_lambda
  sensitive = true
}

output "aws_region_lambda" {
  value     = var.aws_region_lambda
  sensitive = true
}

output "aws_lambda_function_name" {
  value     = var.aws_lambda_function_name
  sensitive = true
}

output "bot_token" {
  value     = var.bot_token
  sensitive = true
}

output "chat_id" {
  value     = var.chat_id
  sensitive = true
}

output "nfs_server" {
  value = var.nfs_server
}

output "nfs_share" {
  value = var.nfs_share
}

output "nfs_share_encrypted" {
  value = var.nfs_share_encrypted
}

output "base_url_private" {
  value     = var.base_url_private
  sensitive = true
}

output "base_url_public" {
  value = var.base_url_public
}

output "base_url_portfolio" {
  value = var.base_url_portfolio
}