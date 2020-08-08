function(
  centralConfigImage = "nginx",
  namespace = "hello",
  namePrefix = "",
  nameSuffix = "-central-config",
  MAIN_HOSTNAME = "central-config.local",
  JWT_KEY = ""
)

local centralConfig = (import '../components/central-config/map.json');
local centralApiHostname = if MAIN_HOSTNAME != null then MAIN_HOSTNAME else centralConfig.data.CENTRAL_CONFIG_API_HOSTNAME;
local centralJwtKey = if JWT_KEY != "" then JWT_KEY else if centralConfig.data.JWT_CENTRAL_CONFIG_KEY != "" then centralConfig.data.JWT_CENTRAL_CONFIG_KEY;

(import 'api.libsonnet') (
    apiImage = centralConfigImage,
    namePrefix = namePrefix, nameSuffix = nameSuffix, namespace = namespace,
    MAIN_HOSTNAME = centralApiHostname
)
{
  api_config+: {
    data+: {
      [if centralJwtKey != "" then "JWT_KEY"]: centralJwtKey,
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
