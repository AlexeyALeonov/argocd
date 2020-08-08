function(
  apiImage = "nginx",
  name = "api",
  namespace = "hello",
  namePrefix = "",
  nameSuffix = "",
  MAIN_HOSTNAME = "hello.svc"
)

local kube = import '../kube-libsonnet/kube.libsonnet';
local utils = import '../kube-libsonnet/utils.libsonnet';

local Namespace = {
  metadata+: {
    namespace: namePrefix + namespace + nameSuffix
  },
};

local labels = {
  metadata+: {
    local this = self,
    labels+: {
      "k8s-app": this.name
    },
  },
};

{
  ns: kube.Namespace(Namespace.metadata.namespace),

  api_config: kube.ConfigMap(namePrefix + 'app-config' + nameSuffix) + Namespace {
    data+: {
      altGreeting: "Good Morning!",
      enableRisky: "false"
    },
  },

  deployments: utils.HashedConfigMap(namePrefix + 'deployments' + nameSuffix) + Namespace,

  sealedSecret:: kube.SealedSecret('databases'),

  databases: self.sealedSecret + Namespace {
    local this = self,
    local secret = utils.HashedSecret(namePrefix + $.sealedSecret.metadata.name + nameSuffix) {
      data: $.sealedSecret.spec.encryptedData
    },
    metadata+: {
      name: secret.metadata.name,
    },
    spec+: {
      template+: {
        metadata+: {
          name: this.metadata.name,
          namespace: this.metadata.namespace
        },
      },
    },
  },

  api_svc: kube.Service($.api.metadata.name) + Namespace + labels {
    target_pod: $.api.spec.template,
    spec+: {
      ports: [{ port: 80, targetPort: 80 }],
      selector: $.api.metadata.labels,
    },
  },

  api: kube.Deployment(namePrefix + name + nameSuffix) + Namespace + labels {
    spec+: {
      replicas: 1,
      template+: {
        spec+: {
          containers_+: {
            api: kube.Container(name) {
              image: apiImage,
              ports_+: { http: { containerPort: 80 } },
              envFrom: [
                {
                  configMapRef: {
                    name: $.api_config.metadata.name,
                  },
                },
              ],
              volumeMounts_+: {
                "app-deployments-volume": {
                  mountPath: '/etc/deployments'
                },
              },
            },
          },
          initContainers_+: {
            "inject-databases": kube.Container("inject-databases") {
              image: 'alpine',
              volumeMounts_+: {
                "config-template-volume": {
                  mountPath: '/deployments',
                },
                "databases-volume": {
                  mountPath: '/databases',
                },
                "app-deployments-volume": {
                  mountPath: '/output',
                },
              },
              command: [
                '/bin/sh',
                '-c',
              ],
              args: [
                "apk add jq\njq '.' -s /deployments/*.json >/tmp/_tmp_deployments.json\njq 'add' -s /databases/*.json >/tmp/_tmp_databases.json\njq '.[1] as $databases | [.[0] | .[] | .DatabaseInfo.Server as $server | .DatabaseInfo *= ($databases | .[$server] // {})]' -s /tmp/_tmp_deployments.json /tmp/_tmp_databases.json >/output/deployments.json\n",
              ],
            },
          },
          volumes_+: {
            "app-deployments-volume": kube.EmptyDirVolume(),
            "config-template-volume": kube.ConfigMapVolume($.deployments),
            "databases-volume": kube.SecretVolume($.databases),
          },
        },
      },
    },
  },

  api_ing: kube.Ingress($.api.metadata.name) + Namespace + labels {
    metadata+: {
      annotations+: {
        "nginx.org/proxy-connect-timeout": "30s",
        "nginx.org/proxy-read-timeout": "20s",
        "nginx.org/client-max-body-size": "4m"
      },
    },
    spec+: {
      rules: [
        {
          host: MAIN_HOSTNAME,
          http: {
            paths: [
              {
                path: "/",
                backend: $.api_svc.name_port,
              },
            ],
          },
        }
      ],
    },
  },
}
