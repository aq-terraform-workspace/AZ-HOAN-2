virtual_network_gateways = {
  main = {
    name                       = "main"
    resource_group_key         = "network"
    type                       = "Vpn"
    sku                        = "VpnGw1"
    private_ip_address_enabled = true
    # enable_bpg defaults to false. If set, true, input the necessary parameters as well. VPN Type only
    enable_bgp = false
    vpn_type   = "RouteBased"
    # multiple IP configs are needed for active_active state. VPN Type only.
    ip_configuration = {
      ipconfig1 = {
        ipconfig_name         = "gatewayIp1"
        public_ip_address_key = "vngw"
        vnet_key                      = "main"
        private_ip_address_allocation = "Static"
      }
    }

    vpn_client_configuration = {
      # The following vpn client config allows AzureAD authentication together with certificate authentication
      vpnconfig1 = {
        address_space = ["10.1.0.0/16"]

        vpn_auth_types       = ["AAD", "Certificate"]
        vpn_client_protocols = ["OpenVPN"]

        aad_audience = "41b23e61-6c1e-4545-b367-cd054e0ed4b4" #Azure VPN Client ApplicationId
        aad_issuer   = "https://sts.windows.net/c14b46fc-2780-4bee-bcfa-e3f5a1c337b9/"
        aad_tenant   = "https://login.microsoftonline.com/c14b46fc-2780-4bee-bcfa-e3f5a1c337b9/"

        revoked_certificate = {
          revoked_a = {
            name       = "Verizon-Global-Root-CA2"
            thumbprint = "912198EEF23DCAC40939312FEE97DD560BAE49B1"
          }
          revoked_b = {
            name       = "Verizon-Global-Root-CA"
            thumbprint = "912198EEF23DCAC40939312FEE97DD560BAE49B2"
          }
        }
        root_certificate = {
          name             = "Verizon-Global-Root-CA"
          public_cert_data = <<EOF
              MIIDuzCCAqOgAwIBAgIQCHTZWCM+IlfFIRXIvyKSrjANBgkqhkiG9w0BAQsFADBn
              MQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3
              d3cuZGlnaWNlcnQuY29tMSYwJAYDVQQDEx1EaWdpQ2VydCBGZWRlcmF0ZWQgSUQg
              Um9vdCBDQTAeFw0xMzAxMTUxMjAwMDBaFw0zMzAxMTUxMjAwMDBaMGcxCzAJBgNV
              BAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdp
              Y2VydC5jb20xJjAkBgNVBAMTHURpZ2lDZXJ0IEZlZGVyYXRlZCBJRCBSb290IENB
              MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAvAEB4pcCqnNNOWE6Ur5j
              QPUH+1y1F9KdHTRSza6k5iDlXq1kGS1qAkuKtw9JsiNRrjltmFnzMZRBbX8Tlfl8
              zAhBmb6dDduDGED01kBsTkgywYPxXVTKec0WxYEEF0oMn4wSYNl0lt2eJAKHXjNf
              GTwiibdP8CUR2ghSM2sUTI8Nt1Omfc4SMHhGhYD64uJMbX98THQ/4LMGuYegou+d
              GTiahfHtjn7AboSEknwAMJHCh5RlYZZ6B1O4QbKJ+34Q0eKgnI3X6Vc9u0zf6DH8
              Dk+4zQDYRRTqTnVO3VT8jzqDlCRuNtq6YvryOWN74/dq8LQhUnXHvFyrsdMaE1X2
              DwIDAQABo2MwYTAPBgNVHRMBAf8EBTADAQH/MA4GA1UdDwEB/wQEAwIBhjAdBgNV
              HQ4EFgQUGRdkFnbGt1EWjKwbUne+5OaZvRYwHwYDVR0jBBgwFoAUGRdkFnbGt1EW
              jKwbUne+5OaZvRYwDQYJKoZIhvcNAQELBQADggEBAHcqsHkrjpESqfuVTRiptJfP
              9JbdtWqRTmOf6uJi2c8YVqI6XlKXsD8C1dUUaaHKLUJzvKiazibVuBwMIT84AyqR
              QELn3e0BtgEymEygMU569b01ZPxoFSnNXc7qDZBDef8WfqAV/sxkTi8L9BkmFYfL
              uGLOhRJOFprPdoDIUBB+tmCl3oDcBy3vnUeOEioz8zAkprcb3GHwHAK+vHmmfgcn
              WsfMLH4JCLa/tRYL+Rw/N3ybCkDp00s0WUZ+AoDywSl0Q/ZEnNY0MsFiw6LyIdbq
              M/s/1JRtO3bDSzD9TazRVzn2oBqzSa8VgIo5C1nOnoAKJTlsClJKvIhnRlaLQqk=
              EOF
        }
      }
    }
  }
}