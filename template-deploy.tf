resource "azurerm_resource_group" "startstopvm" {
  name     = "${local.name_prefix}-StartStopVM"
  location = "southcentralus"

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_resource_group_template_deployment" "example" {
  name                = "${local.name_prefix}-StartStopVM"
  resource_group_name = azurerm_resource_group.startstopvm.name
  deployment_mode     = "Incremental"
  parameters_content = jsonencode({
    "resourceGroupName" = {
      value = "${local.name_prefix}-StartStopVM"
    },
    "resourceGroupRegion" = {
      value = "southcentralus"
    },
    "azureFunctionAppName" = {
      value = "${local.name_prefix}-StartStopVM"
    },
    "applicationInsightsName" = {
      value = "${local.name_prefix}-StartStopVM"
    },
    "applicationInsightsRegion" = {
      value = "southcentralus"
    },
    "storageAccountName" = {
      value = "${local.name_prefix}StartStopVM"
    }
  })
  template_content = <<TEMPLATE
{
  "$schema": "https://schema.management.azure.com/schemas/2018-05-01/subscriptionDeploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "resourceGroupName": {
      "type": "string",
      "metadata": { "description": "The name of the Azure resource group that will contain the Start/Stop components." }
    },
    "resourceGroupRegion": {
      "type": "string",
      "defaultValue": "southcentralus",
      "metadata": { "description": "The region where the resource group containing the Start/Stop components will be located." }
    },
    "azureFunctionAppName": {
      "type": "string",
      "minLength": 2,
      "maxLength": 46,
      "metadata": { "description": "The name of the Azure Function App that will perform the action on the VM(s). This Function App name MUST be globally unique, contain ONLY alphanumeric characters or hyphens (and can NOT start or end with a hyphen), and the length of the name MUST be less than 46 characters." }
    },
    "applicationInsightsName": {
      "type": "string",
      "metadata": { "description": "The name of the Application Insights instance that will hold the analytics for Start/Stop." }
    },
    "applicationInsightsRegion": {
      "type": "string",
      "defaultValue": "southcentralus",
      "metadata": { "description": "The region where the Application Insights instance for Start/Stop Analytics will be located." }
    },
    "storageAccountName": {
      "type": "String",
      "minLength": 3,
      "maxLength": 18,
      "metadata": { "description": "The name of the storage account for Start/Stop execution data logging. Name MUST be globally unique and contain only lowercase letters and numbers. Length of the name MUST be less than 18 characters." }
    },
    "Email Addresses": {
      "type": "string",
      "defaultValue": "",
      "metadata": {
        "description": "Enter one more email addresses that will receive Start/Stop status emails. Seperate emails by using comma(,).",
        "category": "Email Functionality"
      }
    }
  },
  "variables": {
    "branch": "__Branch__",
    "_artifactsLocation": "https://startstopv2prod.blob.core.windows.net/artifacts",
    "nestedTemplates": {
      "StartStopV2_Automation": "[concat(variables('_artifactsLocation'), '/nestedtemplates/Automation.json',variables('sas'))]",
      "StartStopV2_AlertEmail": "[concat(variables('_artifactsLocation'), '/nestedtemplates/AlertEmail.json',variables('sas'))]",
      "StartStopV2_AzDashboard": "[concat(variables('_artifactsLocation'), '/nestedtemplates/AzDashboard.json',variables('sas'))]"
    },
    "Owner": "[concat('/subscriptions/', subscription().subscriptionId, '/providers/Microsoft.Authorization/roleDefinitions/', '8e3af657-a8ff-443c-a75c-2fe8c4bcb635')]",
    "Contributor": "[concat('/subscriptions/', subscription().subscriptionId, '/providers/Microsoft.Authorization/roleDefinitions/', 'b24988ac-6180-42a0-ab88-20f7382dd24c')]",
    "Reader": "[concat('/subscriptions/', subscription().subscriptionId, '/providers/Microsoft.Authorization/roleDefinitions/', 'acdd72a7-3385-48ef-bd42-f606fba81ae7')]",
    "scopeSub": "[subscription().id]",
    "sas": "?sv=2019-02-02&st=2020-06-24T00%3A29%3A01Z&se=2030-06-25T00%3A29%3A00Z&sr=c&sp=r&sig=b8ZTNoY46IANeOadIpzSfEXaBcwymkEhF8v3ICnKhps%3D",
    "azureCloudEnvironment": "AzureGlobalCloud"
  },
  "resources": [
    {
      "type": "Microsoft.Resources/deployments",
      "apiVersion": "2018-05-01",
      "name": "StartStopV2_Automation",
      "resourceGroup": "[parameters('resourceGroupName')]",
      "dependsOn": [ "[resourceId('Microsoft.Resources/resourceGroups/', parameters('resourceGroupName'))]" ],
      "properties": {
        "mode": "Incremental",
        "templateLink": {
          "uri": "[variables('nestedTemplates').StartStopV2_Automation]",
          "contentVersion": "1.0.0.0"
        },
        "parameters": {
          "resourceGroupName": { "value": "[parameters('resourceGroupName')]" },
          "resourceGroupRegion": { "value": "[parameters('resourceGroupRegion')]" },
          "azureFunctionName": { "value": "[parameters('azureFunctionAppName')]" },
          "appInsightName": { "value": "[parameters('applicationInsightsName')]" },
          "appInsightRegion": { "value": "[parameters('applicationInsightsRegion')]" },
          "storageAccountName": { "value": "[parameters('storageAccountName')]" },
          "AzureCloudEnvironment": { "value": "[variables('azureCloudEnvironment')]" }
        }
      }
    },
    {
      "type": "Microsoft.Resources/deployments",
      "apiVersion": "2018-05-01",
      "name": "StartStopV2_CreateAlerts",
      "resourceGroup": "[parameters('resourceGroupName')]",
      "dependsOn": [ "[resourceId('Microsoft.Resources/resourceGroups/', parameters('resourceGroupName'))]", "StartStopV2_Automation" ],
      "properties": {
        "mode": "Incremental",
        "templateLink": {
          "uri": "[variables('nestedTemplates').StartStopV2_AlertEmail]",
          "contentVersion": "1.0.0.0"
        },
        "parameters": {
          "Email Addresses": { "value": "[if(equals(parameters('Email Addresses'),''), 'xlkjciekc321c3@microsoft.com', parameters('Email Addresses'))]" },
          "appInsightName": { "value": "[parameters('applicationInsightsName')]" },
          "appInsightRegion": { "value": "[parameters('applicationInsightsRegion')]" }
        }
      }
    },
    {
      "type": "Microsoft.Resources/deployments",
      "apiVersion": "2018-05-01",
      "name": "StartStopV2_AzDashboard",
      "resourceGroup": "[parameters('resourceGroupName')]",
      "dependsOn": [ "[resourceId('Microsoft.Resources/resourceGroups/', parameters('resourceGroupName'))]", "StartStopV2_Automation", "StartStopV2_CreateAlerts" ],
      "properties": {
        "mode": "Incremental",
        "templateLink": {
          "uri": "[variables('nestedTemplates').StartStopV2_AzDashboard]",
          "contentVersion": "1.0.0.0"
        },
        "parameters": {
          "appInsightName": { "value": "[parameters('applicationInsightsName')]" },
          "appInsightRegion": { "value": "[parameters('applicationInsightsRegion')]" }
        }
      }
    },
    {
      "type": "Microsoft.Authorization/roleAssignments",
      "apiVersion": "2019-04-01-preview",
      "name": "[guid(uniqueString(parameters('resourceGroupName')))]",
      "dependsOn": [ "[resourceId('Microsoft.Resources/resourceGroups/', parameters('resourceGroupName'))]", "StartStopV2_Automation", "StartStopV2_CreateAlerts", "StartStopV2_AzDashboard" ],
      "properties": {
        "roleDefinitionId": "[variables('Contributor')]",
        "principalId": "[reference('StartStopV2_Automation').outputs.pId.value]",
        "principalType": "ServicePrincipal",
        "scope": "[variables('scopeSub')]"
      }
    }
  ],
  "outputs": {}
}
TEMPLATE

  // NOTE: whilst we show an inline template here, we recommend
  // sourcing this from a file for readability/editor support
}

output arm_example_output {
  value = jsondecode(azurerm_resource_group_template_deployment.example.output_content).exampleOutput.value
}