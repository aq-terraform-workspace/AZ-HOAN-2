import sys
import os
import json
import subprocess
from dotenv import load_dotenv
from jinja2 import Template

# Vars
azure_envs = ['ARM_TENANT_ID', 'ARM_SUBSCRIPTION_ID', 'ARM_CLIENT_ID', 'ARM_CLIENT_SECRET']

# Load env from .env file
load_dotenv()

def preq(arg=''):
  print('Installing prerequisite tools...')
  os.system(f'choco install terraform -y {arg}')
  os.system(f'choco install azure-cli -y {arg}')
  os.system(f'choco install kubernetes-cli -y {arg}')
  os.system(f'choco install kubernetes-helm -y {arg}')

def print_vars():
  print("Environment variables")
  print("----------------------------------")
  for var in azure_envs:
    print(var + ": " + str(os.getenv(var)))

def check_vars():
  is_enough = True
  message = ""
  for var in azure_envs:
    if os.getenv(var) is None:
      message += f"[ERROR] {var} variable is not set\n"
      is_enough = False
  print(message)
  return is_enough
  
def az_login():
  if check_vars():
    output = os.popen('az account show').read()
    if output:
      current_user = json.loads(output)['user']['name']
      default_user = os.getenv("ARM_CLIENT_ID")

      if current_user != default_user:
        print(f"Already logged in as '{current_user}', performing logout...")
        os.system('az logout')
        print("Performing login...")
        result = os.system(f'az login --service-principal -u {os.getenv("ARM_CLIENT_ID")} -p {os.getenv("ARM_CLIENT_SECRET")} --tenant {os.getenv("ARM_TENANT_ID")}')
        if result == 0:
          return True
        else:
          print("Error occurred while using `az login`")
          return False
      else:
        print(f"Already logged in as '{current_user}' to Azure.")
        return True
    else:
      print("Not logged in to Azure. Performing login...")
      result = os.system(f'az login --service-principal -u {os.getenv("ARM_CLIENT_ID")} -p {os.getenv("ARM_CLIENT_SECRET")} --tenant {os.getenv("ARM_TENANT_ID")}')
      if result == 0:
        return True
      else:
        print("Error occurred while using `az login`")
        return False
  else:
    return False
  

def init():
  if az_login():
    # Generate backend config file
    print('Generating backend config file...')
    vars = {
      "TFSTATE_RG_NAME" : os.getenv("TFSTATE_RG_NAME"),
      "TFSTATE_SA_NAME" : os.getenv("TFSTATE_SA_NAME"),
      "TFSTATE_CONTAINER_NAME": os.getenv("TFSTATE_CONTAINER_NAME")
    }

    with open('scripts/templates/backend.conf.j2') as f:
        template = Template(f.read(), keep_trailing_newline=True)

    template_rendered = template.render(vars)
    output_file = 'backend.conf'
    with open(output_file, 'w') as f:
        f.write(template_rendered)

    print('Creating tfstate storage account...')
    os.system(f'az group create --name {os.getenv("TFSTATE_RG_NAME")} --location {os.getenv("TFSTATE_LOCATION")}')
    os.system(f'az storage account create --resource-group {os.getenv("TFSTATE_RG_NAME")} --name {os.getenv("TFSTATE_SA_NAME")} --sku Standard_LRS --encryption-services blob')
    os.environ["ARM_ACCESS_KEY"] = subprocess.getoutput(f'az storage account keys list --resource-group {os.getenv("TFSTATE_RG_NAME")} --account-name {os.getenv("TFSTATE_SA_NAME")} --query [0].value -o tsv')
    os.system(f'az storage container create --name {os.getenv("TFSTATE_CONTAINER_NAME")} --account-name {os.getenv("TFSTATE_SA_NAME")} --account-key {os.getenv("ARM_ACCESS_KEY")}')
  
def terraform(arg):
  if arg == 'init':
    message = f'Running `terraform init` on subscription {os.getenv("ARM_SUBSCRIPTION_ID")} ...'
    command = f'terraform init -backend-config=backend.conf'
  elif arg == 'init-upgrade':
    message = f'Running `terraform init` on subscription {os.getenv("ARM_SUBSCRIPTION_ID")} ...'
    command = f'terraform init -upgrade -backend-config=backend.conf'
  elif arg == 'plan':
    message = f'Running `terraform plan` on subscription {os.getenv("ARM_SUBSCRIPTION_ID")} ...'
    command = f'terraform plan -input=false -out terraform.tfplan'
  elif arg == 'apply':
    message = f'Running `terraform apply` on subscription {os.getenv("ARM_SUBSCRIPTION_ID")} ...'
    command = f'terraform apply -input=false terraform.tfplan'
  elif arg == 'destroy':
    message = f'Running `terraform apply` on subscription {os.getenv("ARM_SUBSCRIPTION_ID")} ...'
    command = f'terraform destroy -input=false'
  
  if az_login():
    # Get backend access key
    print("Getting Backend access key...")
    os.environ["ARM_ACCESS_KEY"] = subprocess.getoutput(f'az storage account keys list --resource-group {os.getenv("TFSTATE_RG_NAME")} --account-name {os.getenv("TFSTATE_SA_NAME")} --query [0].value -o tsv')
    if os.getenv("ARM_ACCESS_KEY") is None:
      print(f"[ERROR] Cannot get ARM_ACCESS_KEY variable")
      return False
    # Run Terraform command
    print(message)
    result = os.system(command)
    if result == 0:
      return True
    else:
      print('Error occurred while running terraform command')
      return False

def bootstrap():
  init = terraform('init')
  if init:
    plan = terraform('plan')
    if plan:
      confirmation = input('Do you want to proceed `terraform apply`? (Y/N): ')
      if confirmation.lower() == 'y':
          return terraform('apply')
      else:
          return False

def app():
  if az_login():
    load_dotenv('addons/.env')
    print('Getting AKS kubernetes config...')
    result = os.system(f'az aks get-credentials --resource-group {os.getenv("AKS_RG_NAME")} --name {os.getenv("AKS_CLUSTER_NAME")} --public-fqdn --admin --overwrite-existing')
    if result == 0:
      # Helm install addons
      print('Adding all required repos...')
      os.system('helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx')
      os.system('helm repo add cert-manager https://charts.jetstack.io')
      os.system('helm repo add prefect-system https://prefecthq.github.io/prefect-helm')
      os.system('helm repo update')

      print('Installing ingress-nginx...')
      os.system(f'helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx -n ingress-nginx --create-namespace -f addons/ingress-nginx/values.yaml --version {os.getenv("INGRESS_NGINX_VERSION")}')

      print('Installing cert-manager...')
      os.system(f'helm upgrade --install cert-manager cert-manager/cert-manager -n cert-manager --create-namespace -f addons/cert-manager/values.yaml --version {os.getenv("CERT_MANAGER_VERSION")}')
      if os.getenv("CERT_MANAGER_INSTALL_ADDITIONAL_MANIFEST") == 'true':
        os.system(f'kubectl apply -k addons/cert-manager/manifests')

      print('Installing prefect-server...')
      os.system(f'helm upgrade --install prefect-server prefect-system/prefect-server -n prefect-system --create-namespace -f addons/prefect-system/values-server.yaml --version {os.getenv("PREFECT_VERSION")}')
      
      print('Installing prefect-agent...')
      os.system(f'helm upgrade --install prefect-agent prefect-system/prefect-agent -n prefect-system --create-namespace -f addons/prefect-system/values-agent.yaml --version {os.getenv("PREFECT_VERSION")}')
    else:
      print('Error occurred while getting AKS config')
      return False

if __name__ == '__main__':
    args = sys.argv
    # args[0] = current file
    # args[1] = function name
    # args[2:] = function args : (*unpacked)
    globals()[args[1]](*args[2:])