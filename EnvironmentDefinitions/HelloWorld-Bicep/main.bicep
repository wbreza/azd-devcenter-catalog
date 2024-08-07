@minLength(1)
@maxLength(64)
@description('Name of the the environment which is used to generate a short unique hash used in all resources.')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string = resourceGroup().location

param serviceName string = ''
param appServicePlanName string = ''
param repoUrl string = ''

var abbrs = loadJsonContent('./abbreviations.json')
var resourceToken = toLower(uniqueString(subscription().id, resourceGroup().name, environmentName, location))
var tags = { 'azd-env-name': environmentName }

// The application backend
module helloworld './app/helloworld.bicep' = {
  name: 'helloworld'
  scope: resourceGroup()
  params: {
    name: !empty(serviceName) ? serviceName : '${abbrs.webSitesAppService}helloworld-${resourceToken}'
    location: location
    tags: tags
    appServicePlanId: appServicePlan.outputs.id
  }
}

// Create an App Service Plan to group applications under the same payment plan and SKU
module appServicePlan './core/host/appserviceplan.bicep' = {
  name: 'appserviceplan'
  scope: resourceGroup()
  params: {
    name: !empty(appServicePlanName) ? appServicePlanName : '${abbrs.webServerFarms}${resourceToken}'
    location: location
    tags: tags
    sku: {
      name: 'B3'
    }
  }
}

// App outputs
output AZURE_LOCATION string = location
output AZURE_TENANT_ID string = tenant().tenantId
output SERVICE_API_ENDPOINTS array = [helloworld.outputs.SERVICE_HELLOWORLD_URI]

output TEST_ARRAY array = ['test1', 'test2']

output TEST_OBJECT object = { key1: 'value1', key2: 'value2' }

output TEST_BOOL bool = true

output TEST_INT int = 123

output TEST_STRING string = 'test'
