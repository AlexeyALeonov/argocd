function(
  centralConfigImage = "nginx",
  namespace = "hello",
  namePrefix = "",
  nameSuffix = "-central-config",
  MAIN_HOSTNAME = "central-config.local",
  JWT_KEY = null
)

(import 'api.libsonnet') (
    apiImage = centralConfigImage,
    namePrefix = namePrefix, nameSuffix = nameSuffix, namespace = namespace
)
{
  centralConfig:: (import '../components/central-config/map.json'),
  MAIN_HOSTNAME:: if MAIN_HOSTNAME != null then MAIN_HOSTNAME else self.centralConfig.data.CENTRAL_CONFIG_API_HOSTNAME,
  local centralJwtKey = if JWT_KEY != null then JWT_KEY else if self.centralConfig.data.JWT_CENTRAL_CONFIG_KEY != null then self.centralConfig.data.JWT_CENTRAL_CONFIG_KEY,

  api_config+: {
    data+: {
      [if centralJwtKey != null then "JWT_KEY"]: centralJwtKey,
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
