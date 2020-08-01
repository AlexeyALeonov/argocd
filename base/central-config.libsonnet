function(
  apiImage="nginx",
  namespace="hello",
  namePrefix="",
  nameSuffix="-central-config",
  JWT_KEY="",
  MAIN_HOSTNAME="central-config.local"
)

(import 'api.libsonnet') (
    apiImage=apiImage, 
    namePrefix=namePrefix, nameSuffix=nameSuffix, namespace=namespace,
    MAIN_HOSTNAME=MAIN_HOSTNAME
)
{
  api_config+: {
    data+: {
      [if JWT_KEY != "" then "JWT_KEY"]: JWT_KEY,
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
