output "depend_value" {
  value = "Terraform"
  depends_on = ["null_resource.install_az_cli"]
}