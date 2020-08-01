function(
  apiImage="nginx",
  namespace="hello",
  namePrefix="",
  nameSuffix="-auth",
  JWT_KEY="",
  CENTRAL_CONFIG_API_URL=null,
  JWT_CENTRAL_CONFIG_KEY="",
  MAIN_HOSTNAME="auth.local"
)

local centralConfig = (import '../components/central-config/map.json');
local centralApiUrl = if CENTRAL_CONFIG_API_URL != null then CENTRAL_CONFIG_API_URL else if centralConfig.data.CENTRAL_CONFIG_API_HOSTNAME != null then "http://" + centralConfig.data.CENTRAL_CONFIG_API_HOSTNAME;
local centralJwtKey = if JWT_CENTRAL_CONFIG_KEY != "" then JWT_CENTRAL_CONFIG_KEY else if centralConfig.data.JWT_CENTRAL_CONFIG_KEY != "" then centralConfig.data.JWT_CENTRAL_CONFIG_KEY;

local authConfig = (import '../components/auth/map.json');
local authApiHostname = if MAIN_HOSTNAME != null then MAIN_HOSTNAME else if authConfig.data.AUTH_API_HOSTNAME != null then authConfig.data.AUTH_API_HOSTNAME;
local authJwtKey = if JWT_KEY != "" then JWT_KEY else if authConfig.data.JWT_AUTH_KEY != "" then authConfig.data.JWT_AUTH_KEY;

(import 'api.libsonnet') (
    apiImage=apiImage, 
    namePrefix=namePrefix, nameSuffix=nameSuffix, namespace=namespace,
    MAIN_HOSTNAME=authApiHostname
)
{
  api_config+: {
    data+: {
      [if CENTRAL_CONFIG_API_URL != null then "CENTRAL_CONFIG_API_URL"]: centralApiUrl,
      [if JWT_CENTRAL_CONFIG_KEY != "" then "JWT_CENTRAL_CONFIG_KEY"]: centralJwtKey,
      [if JWT_KEY != "" then "JWT_KEY"]: authJwtKey,
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
