function(
  authImage = "nginx",
  namespace = "hello",
  namePrefix = "",
  nameSuffix = "-auth",
  MAIN_HOSTNAME = "auth.local",
  JWT_KEY = null,
  CENTRAL_CONFIG_API_URL = null,
  JWT_CENTRAL_CONFIG_KEY = null
)


(import 'api.libsonnet') (
    apiImage = authImage,
    namePrefix = namePrefix, nameSuffix = nameSuffix, namespace = namespace
)
{
  authConfig:: (import '../components/auth/map.json'),
  MAIN_HOSTNAME:: if MAIN_HOSTNAME != null then MAIN_HOSTNAME else if self.authConfig.data.AUTH_API_HOSTNAME != null then self.authConfig.data.AUTH_API_HOSTNAME,
  authJwtKey:: if JWT_KEY != null then JWT_KEY else if self.authConfig.data.JWT_AUTH_KEY != null then self.authConfig.data.JWT_AUTH_KEY,

  centralConfig:: (import '../components/central-config/map.json'),
  local centralApiUrl = if CENTRAL_CONFIG_API_URL != null then CENTRAL_CONFIG_API_URL else if self.centralConfig.data.CENTRAL_CONFIG_API_HOSTNAME != null then "http://" + self.centralConfig.data.CENTRAL_CONFIG_API_HOSTNAME,
  local centralJwtKey = if JWT_CENTRAL_CONFIG_KEY != null then JWT_CENTRAL_CONFIG_KEY else if self.centralConfig.data.JWT_CENTRAL_CONFIG_KEY != null then self.centralConfig.data.JWT_CENTRAL_CONFIG_KEY,

  api_config+: {
    data+: {
      [if centralApiUrl != null then "CENTRAL_CONFIG_API_URL"]: centralApiUrl,
      [if centralJwtKey != null then "JWT_CENTRAL_CONFIG_KEY"]: centralJwtKey,
      [if $.authJwtKey != null then "JWT_KEY"]: $.authJwtKey,
    },
  },

  // hide deployments and databases
  deployments:: super.deployments,
  databases:: super.databases,

  api+: {
    spec+: {
      template+: {
        spec+: {
          containers_+: {
            api+: {
              volumeMounts:: super.volumeMounts,
            },
          },
          initContainers:: super.initContainers,
          volumes:: super.volumes,
        },
      },
    },
  },
}
