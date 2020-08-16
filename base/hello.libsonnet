function(
  apiImage = "nginx",
  uiImage = "nginx",
  nginxImage = "nginx",
  namespace = "hello",
  namePrefix = "",
  nameSuffix = "",
  MAIN_HOSTNAME = "hello.local",
  AUTH_API_URL = null,
  JWT_AUTH_KEY = null,
  API_HOSTNAME = null,
  UI_HOSTNAME = null
)

local kube = import '../kube-libsonnet/kube.libsonnet';

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

local api = (import 'api.libsonnet') (apiImage = apiImage, namePrefix = namePrefix, nameSuffix = nameSuffix, namespace = namespace) {
  authConfig:: import '../components/auth/map.json',
  authJwtKey:: if JWT_AUTH_KEY != null then JWT_AUTH_KEY else if self.authConfig.data.JWT_AUTH_KEY != null then self.authConfig.data.JWT_AUTH_KEY,
  authApiUrl:: if AUTH_API_URL != null then AUTH_API_URL else if self.authConfig.data.AUTH_API_HOSTNAME != null then "https://" + self.authConfig.data.AUTH_API_HOSTNAME + "/api",

  api_config+: {
    data+: {
      [if $.authJwtKey != null then "JWT_AUTH_KEY"]: $.authJwtKey,
    },
  },

  api_ing:: super.api_ing,
};

api + {
  ui_config: kube.ConfigMap(namePrefix + 'ui-config' + nameSuffix) + Namespace {
    data+: {
      [if $.authApiUrl != null then "AUTH_API_URL"]: $.authApiUrl,
      [if $.authJwtKey != null then "JWT_AUTH_KEY"]: $.authJwtKey,
    },
  },

  nginx_config: kube.ConfigMap(namePrefix + 'nginx-config' + nameSuffix) + Namespace {
    data+: {
      MAIN_HOSTNAME: MAIN_HOSTNAME,
      API_HOSTNAME: if API_HOSTNAME == null then $.api_svc.host else API_HOSTNAME,
      UI_HOSTNAME: if UI_HOSTNAME == null then $.ui_svc.host else UI_HOSTNAME,
    },
  },

  ui_svc: kube.Service($.ui.metadata.name) + Namespace {
    target_pod: $.ui.spec.template,
    spec+: {
      ports: [{ port: 80, targetPort: 80 }],
      selector: $.ui.metadata.labels,
    },
  },

  ui: kube.Deployment(namePrefix + 'ui' + nameSuffix) + Namespace + labels {
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
                    name: $.ui_config.metadata.name,
                  },
                },
              ],
            },
          },
        },
      },
    },
  },

  nginx_svc: kube.Service($.nginx.metadata.name) + Namespace + labels {
    target_pod: $.nginx.spec.template,
    spec+: {
      ports: [{ port: 80, targetPort: 80 }],
      selector: $.nginx.metadata.labels,
    },
  },

  nginx: kube.Deployment(namePrefix + 'nginx' + nameSuffix) + Namespace + labels {
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
                    name: $.nginx_config.metadata.name,
                  },
                },
              ],
            },
          },
        },
      },
    },
  },

  nginx_ing: kube.Ingress($.nginx.metadata.name) + Namespace + labels {
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
                backend: $.nginx_svc.name_port,
              },
            ],
          },
        }
      ],
    },
  },
}
