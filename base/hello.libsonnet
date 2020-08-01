function(
  apiImage="nginx",
  uiImage="nginx",
  nginxImage="nginx",
  namespace="hello",
  namePrefix="",
  nameSuffix="",
  AUTH_API_URL=null,
  JWT_AUTH_KEY="",
  MAIN_HOSTNAME="hello.local",
  API_HOSTNAME=null,
  UI_HOSTNAME=null
)

local kube = import '../kube-libsonnet/kube.libsonnet';

local authConfig = (import '../components/auth/map.json');
local authJwtKey = if JWT_AUTH_KEY != "" then JWT_AUTH_KEY else if authConfig.data.JWT_AUTH_KEY != "" then authConfig.data.JWT_AUTH_KEY;

local api = (import 'api.libsonnet') (apiImage=apiImage, namePrefix=namePrefix, nameSuffix=nameSuffix, namespace=namespace) {
  api_config+: {
    data+: {
      JWT_AUTH_KEY: authJwtKey,
    },
  },

  api_ing:: super.api_ing,
};

api + {

  ns: kube.Namespace(namePrefix + namespace + nameSuffix),

  ui_config: kube.ConfigMap(namePrefix + 'ui-config' + nameSuffix) {
    metadata+: {
      namespace: namePrefix + namespace + nameSuffix
    },
    data+: {
      [if AUTH_API_URL != null then "AUTH_API_URL"]: AUTH_API_URL,
      [if JWT_AUTH_KEY != "" then "JWT_AUTH_KEY"]: JWT_AUTH_KEY,
    },
  },

  nginx_config: kube.ConfigMap(namePrefix + 'nginx-config' + nameSuffix) {
    metadata+: {
      namespace: namePrefix + namespace + nameSuffix
    },
    data+: {
      MAIN_HOSTNAME: MAIN_HOSTNAME,
      API_HOSTNAME: if API_HOSTNAME == null then $.api_svc.host else API_HOSTNAME,
      UI_HOSTNAME: if UI_HOSTNAME == null then $.ui_svc.host else UI_HOSTNAME,
    },
  },

  ui_svc: kube.Service(namePrefix + 'ui' + nameSuffix) {
    metadata+: {
      namespace: namePrefix + namespace + nameSuffix,
      labels+: {
        "k8s-app": namePrefix + 'ui' + nameSuffix
      },
    },
    target_pod: $.ui.spec.template,
    spec+: {
      ports: [{ port: 80, targetPort: 80 }],
      selector: { "k8s-app": namePrefix + 'ui' + nameSuffix },
    },
  },

  ui: kube.Deployment(namePrefix + 'ui' + nameSuffix) {
    metadata+: {
      namespace: namePrefix + namespace + nameSuffix,
      labels+: {
        "k8s-app": namePrefix + 'ui' + nameSuffix
      },
    },
    spec+: {
      template+: {
        spec+: {
          containers_+: {
            ui: kube.Container('hello-ui') {
              image: uiImage,
              ports_+: { http: { containerPort: 80 } },
              envFrom: [
                {
                  configMapRef: {
                    name: namePrefix + 'ui-config' + nameSuffix,
                  },
                },
              ],
            },
          },
        },
      },
    },
  },

  nginx_svc: kube.Service(namePrefix + 'nginx' + nameSuffix) {
    metadata+: {
      namespace: namePrefix + namespace + nameSuffix,
      labels+: {
        "k8s-app": namePrefix + 'nginx' + nameSuffix
      },
    },
    target_pod: $.nginx.spec.template,
    spec+: {
      ports: [{ port: 80, targetPort: 80 }],
      selector: { "k8s-app": namePrefix + 'nginx' + nameSuffix },
    },
  },

  nginx: kube.Deployment(namePrefix + 'nginx' + nameSuffix) {
    metadata+: {
      namespace: namePrefix + namespace + nameSuffix,
      labels+: {
        "k8s-app": namePrefix + 'nginx' + nameSuffix
      },
    },
    spec+: {
      template+: {
        spec+: {
          containers_+: {
            nginx: kube.Container('hello-nginx') {
              image: nginxImage,
              ports_+: { http: { containerPort: 80 } },
              envFrom: [
                {
                  configMapRef: {
                    name: namePrefix + 'nginx-config' + nameSuffix,
                  },
                },
              ],
            },
          },
        },
      },
    },
  },

  nginx_ing: kube.Ingress(namePrefix + 'nginx' + nameSuffix) {
    metadata+: {
      annotations+: {
        "nginx.org/proxy-connect-timeout": "30s",
        "nginx.org/proxy-read-timeout": "20s",
        "nginx.org/client-max-body-size": "4m"
      },
      namespace: namePrefix + namespace + nameSuffix,
      labels+: {
        "k8s-app": namePrefix + 'nginx' + nameSuffix
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
                backend: $.nginx_svc.name_port,
              },
            ],
          },
        }
      ],
    },
  },
}
