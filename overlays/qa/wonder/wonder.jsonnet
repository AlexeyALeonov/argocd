function(
  apiImage = "nginx",
  uiImage = "nginx",
  nginxImage = "nginx",
  namespace = "hello",
  namePrefix = "qa-",
  nameSuffix = "-wonder",
  MAIN_HOSTNAME = "wonder-hello.qa.local",
  API_HOSTNAME = null,
  UI_HOSTNAME = null,
  AUTH_API_URL = null,
  JWT_AUTH_KEY = null
)

local kube = import '../../../kube-libsonnet/kube.libsonnet';

local wonder = (import '../../../base/hello.libsonnet') (
  apiImage = apiImage, uiImage = uiImage, nginxImage = nginxImage,
  namePrefix = namePrefix, nameSuffix = nameSuffix, namespace = namespace,
  AUTH_API_URL = AUTH_API_URL, JWT_AUTH_KEY = JWT_AUTH_KEY,
  MAIN_HOSTNAME = MAIN_HOSTNAME
)
{
  authConfig:: (import '../components/auth/map.json'),

  api_config+: {
    data+: {
      altGreeting: "Do you wonder, why a pineapple?",
      enableRisky: "true"
    }
  },

  deployments+: {
    data+: {
      "test_wonder_qa.json": importstr '../components/deployments/wonder/test_wonder_qa.json'
    },
  },

  sealedSecret+:: import '../../../components/databases/test/test_ss.json',

  local annotations = {
    metadata+: {
      annotations+: {
        note: "Wonder, I am QA!"
      },
    },
  },

  api+: annotations,

  ui+: annotations,

  nginx+: annotations,
};

kube.List() {items_+: wonder}