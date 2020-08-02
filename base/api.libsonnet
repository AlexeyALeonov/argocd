function(
  apiImage="nginx",
  name="api",
  namespace="hello",
  namePrefix="",
  nameSuffix="",
  MAIN_HOSTNAME="hello.svc"
)

local kube = import '../kube-libsonnet/kube.libsonnet';

{
  // apiImage:: std.extVar('API_IMAGE'),

  ns: kube.Namespace(namePrefix + namespace + nameSuffix),

  api_config: kube.ConfigMap(namePrefix + 'app-config' + nameSuffix) {
    metadata+: {
      namespace: namePrefix + namespace + nameSuffix
    },
    data+: {
      altGreeting: "Good Morning!",
      enableRisky: "false"
    },
  },

  deployments: kube.ConfigMap(namePrefix + 'deployments' + nameSuffix) {
    metadata+: {
      namespace: namePrefix + namespace + nameSuffix
    }
  },

  databases_name:: {
    metadata+: {
      name: namePrefix + 'databases' + nameSuffix,
      namespace: namePrefix + namespace + nameSuffix
    },
    spec+: {
      template+: {
        metadata+: {
          name: namePrefix + 'databases' + nameSuffix,
          namespace: namePrefix + namespace + nameSuffix
        },
      },
    },
  },

  databases: (import 'api/sealedsecret_databases.json') + self.databases_name,

  api_svc: kube.Service(namePrefix + name + nameSuffix) {
    metadata+: {
      namespace: namePrefix + namespace + nameSuffix,
      labels+: {
        "k8s-app": namePrefix + name + nameSuffix
      },
    },
    target_pod: $.api.spec.template,
    spec+: {
      ports: [{ port: 80, targetPort: 80 }],
      selector: { "k8s-app": namePrefix + name + nameSuffix },
    },
  },

  api: kube.Deployment(namePrefix + name + nameSuffix) {
    metadata+: {
      namespace: namePrefix + namespace + nameSuffix,
      labels+: {
        "k8s-app": namePrefix + name + nameSuffix
      },
    },
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
                    name: namePrefix + 'app-config' + nameSuffix,
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
            "databases-volume": {
              secret: {
                secretName: namePrefix + 'databases' + nameSuffix,
              },
            },
          },
        },
      },
    },
  },

  api_ing: kube.Ingress(namePrefix + name + nameSuffix) {
    metadata+: {
      annotations+: {
        "nginx.org/proxy-connect-timeout": "30s",
        "nginx.org/proxy-read-timeout": "20s",
        "nginx.org/client-max-body-size": "4m"
      },
      namespace: namePrefix + namespace + nameSuffix,
      labels+: {
        "k8s-app": namePrefix + name + nameSuffix
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
