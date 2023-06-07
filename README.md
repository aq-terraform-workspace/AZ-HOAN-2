# Prerequisites
## Chocolatey
```
https://chocolatey.org/install
```
## Python and required modules
```
choco install python -y
```
```
pip install -r scripts/requirements.txt
```
## Other tools
```
python scripts/main.py preq
```
## Install the Azure VPN Enterprise Application
To use the Azure VPN function, you need first to install the Enterprise Application of the Azure VPN into your Azure account

Please follow the steps in this link
```
https://learn.microsoft.com/en-us/azure/vpn-gateway/openvpn-azure-ad-tenant#authorize-the-application
```
Open `vngw.auto.tfvars` => Fill in your Tenant ID at the line `30` and `31`

## Azure Service Principal
This project will use Terraform with AzureRM provider to create all the necessary cloud resources for Prefect (prefect.io) to run on the top of them.

Terraform has many methods to authenticate it with your Azure account to create the cloud resources. One of them that we usually use is Service Principal. Please follow the below Steps to create a SP (Service Principal) with the appropriate RBAC role

### 1. Creation
- Visit https://portal.azure.com
- Login with either Global Administrator or User Administrator account
- Goes to `Azure Active Directory` => `App registrations` => `New Registration` => Fill in the required values:

  - Name of the SP (Eg: Terraform)
  - Accounts in this organizational directory only (hoanlac only - Single tenant)
- Take note the `Application (client) ID` and `Directory (tenant) ID` to use at `Step 3`
- Goes to `Certificate & secrets` => `New client secret` => Take note the `Secret value` to use at `Step 3`

### 2. Assign Subscription RBAC role
- Goes to `Subscription`
- Select the subscription you want to provision the resources in there
- Take note the `Subscription ID` to use at `Step 3`
- Select `Access control (IAM)` => `Role assignments` => Assign the previous Service Principal as `Owner` role to the subscription
- Remember to make sure the role is `Owner`, **NOT** `Contributor` since the Terraform code will need some additional permission from Owner (Eg: Set MSI RBAC role, etc...)

### 3. Update `.env` file
- Open `scripts/.env` inside this repo
- Update the following ENV vars with the information we have taken note from `Step 1`
```
ARM_TENANT_ID
ARM_SUBSCRIPTION_ID
ARM_CLIENT_ID
ARM_CLIENT_SECRET
```
- For the other ENV vars like `TFSTATE_RG_NAME` , you can also change to whatever you want. But remember, the SA (Storage Account) name cannot have space or hyphen (-) in its name

# How to apply?
## 1. Install the prerequisite tools
```
python scripts/main.py preq
```
## 2. Init the Storage Account to store terraform.tfstate
```
python scripts/main.py init
```
## 3. Bootstrap the infrastructures
```
python scripts/main.py bootstrap
```
## 4. Get the VPN configuration and install Azure VPN Client
### Get the VPN configuration
- Visit https://portal.azure.com
- Search for `Virtual network gateways`
- Select the GW created by Terraform. The default is `prefect2-dev-vgw-main`
- Goes to `Point-to-side configuration` => `Download VPN Client` on the top
- Extract the downloaded .zip file

### Install Azure VPN Client
- Open the following link to visit Microsoft Store and install
```
https://go.microsoft.com/fwlink/?linkid=2117554
```

### Import the VPN Profile
- Open the Azure VPN Client => Select the `+` button at the bottom => `Import` => Open the extracted folder above => Open `AzureVPN/azurevpnconfig_aad.xml`
- Connect to the VPN using your Azure Account => Make sure the connection status turn to `GREEN`

## 5. Install the addons into AKS cluster
- Update Prefect domain => Open `addons/prefect-system/values-server.yaml` => Update the `publicApiUrl` and `ingress.hostname`
- Then run
```
python scripts/main.py app
```

## 6. Update DNS record
- Visit domain provider => Update the DNS records point to the Private IP address of the Load Balancer
- The default IP of the Private LB is `10.0.15.100`