function(
  apiImage = "nginx",
  uiImage = "nginx",
  nginxImage = "nginx",
  namespace = "hello",
  namePrefix = "qa-",
  nameSuffix = "-simple",
  MAIN_HOSTNAME = "simple-hello.qa.local",
  API_HOSTNAME = null,
  UI_HOSTNAME = null,
  AUTH_API_URL = null,
  JWT_AUTH_KEY = null
)

local kube = import '../../../kube-libsonnet/kube.libsonnet';

local simple = (import '../../../base/hello.libsonnet') (
  apiImage = apiImage, uiImage = uiImage, nginxImage = nginxImage,
  namePrefix = namePrefix, nameSuffix = nameSuffix, namespace = namespace,
  AUTH_API_URL = AUTH_API_URL, JWT_AUTH_KEY = JWT_AUTH_KEY,
  MAIN_HOSTNAME = MAIN_HOSTNAME
)
{
  authConfig:: (import '../components/auth/map.json'),

  api_config+: {
    data+: {
      altGreeting: "Make it simple!",
      enableRisky: "true"
    }
  },

  deployments+: {
    data+: {
      "test_simple_qa.json": importstr '../components/deployments/simple/test_simple_qa.json'
    },
  },

  sealedSecret+:: import '../../../components/databases/test/test_ss.json',

  local annotations = {
    metadata+: {
      annotations+: {
        note: "Make it simple - I am QA!"
      },
    },
  },

  api+: annotations,

  ui+: annotations,

  nginx+: annotations,
};

kube.List() {items_+: simple}