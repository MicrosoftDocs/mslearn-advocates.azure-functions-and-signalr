param accountName string
param location string = resourceGroup().location
param tags object = {}

resource signalr 'Microsoft.SignalRService/signalR@2023-08-01-preview' = {
  name: accountName
  location: location
  tags: tags
  sku: {
    capacity: 1
    name: 'Free_F1'
    tier: 'Free'
  }
  kind: 'SignalR'
  properties: {
    cors: {
      allowedOrigins: [
        '*'
      ]
    }
    disableAadAuth: false
    disableLocalAuth: false
    features: [
      {
        flag: 'ServiceMode'
        value: 'Serverless'
        properties: {}
    }
    {
        flag: 'EnableConnectivityLogs'
        value: 'False'
        properties: {}
    }
    {
        flag: 'EnableMessagingLogs'
        value: 'False'
        properties: {}
    }
    {
        flag: 'EnableLiveTrace'
        value: 'False'
        properties: {}
    }
    ]
    liveTraceConfiguration: {
      categories: [
        {
          name: 'ConnectivityLogs'
          enabled: 'false'
      }
      {
          name: 'MessagingLogs'
          enabled: 'false'
      }
      {
          name: 'HttpRequestLogs'
          enabled: 'false'
      }
      ]
      enabled: 'true'
    }
    networkACLs: {
      defaultAction: 'Deny'
      ipRules: [
        {
          value: '0.0.0.0/0'
          action: 'Allow'
      }
      {
          value: '::/0'
          action: 'Allow'
      }
      ]
      privateEndpoints: []
      publicNetwork: {
        allow: [
          'ServerConnection'
          'ClientConnection'
          'RESTAPI'
          'Trace'
        ]
      }
    }
    publicNetworkAccess: 'Enabled'
    regionEndpointEnabled: 'Enabled'
    resourceStopped: 'false'
    serverless: {
      connectionTimeoutInSeconds: 30
    }
    tls: {
      clientCertEnabled: false
    }
    upstream: {}
  }
}
