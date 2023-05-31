resource "null_resource" "install_az_cli" {
  provisioner "local-exec" {
    command = <<EOF
      . /etc/lsb-release
      wget https://packages.microsoft.com/repos/azure-cli/pool/main/a/azure-cli/azure-cli_2.36.0-1~$${DISTRIB_CODENAME}_all.deb
      mkdir ./env && dpkg -x *.deb ./env
      ./env/usr/bin/az login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET -t $ARM_TENANT_ID
      ./env/usr/bin/az account show
    EOF
  }
  triggers = {
    always_run = uuid()
  }
}