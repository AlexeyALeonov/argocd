function(
  apiImage = "nginx",
  uiImage = "nginx",
  nginxImage = "nginx",
  namespace = "hello",
  namePrefix = "qa-",
  nameSuffix = "-wonder",
  AUTH_API_URL = null,
  JWT_AUTH_KEY = "",
  MAIN_HOSTNAME = "wonder-hello.qa.local",
  API_HOSTNAME = null,
  UI_HOSTNAME = null
)

local kube = import '../../kube-libsonnet/kube.libsonnet';

local authConfig = (import 'components/auth/map.json');
local authApiUrl = if AUTH_API_URL != null then AUTH_API_URL else if authConfig.data.AUTH_API_HOSTNAME != null then "http://" + authConfig.data.AUTH_API_HOSTNAME;
local authJwtKey = if JWT_AUTH_KEY != "" then JWT_AUTH_KEY else if authConfig.data.JWT_AUTH_KEY != "" then authConfig.data.JWT_AUTH_KEY;

local wonder = (import '../../base/hello.libsonnet') (
  apiImage = apiImage, uiImage = uiImage, nginxImage = nginxImage,
  namePrefix = namePrefix, nameSuffix = nameSuffix, namespace = namespace,
  AUTH_API_URL = authApiUrl, JWT_AUTH_KEY = authJwtKey,
  MAIN_HOSTNAME = MAIN_HOSTNAME
)
{
  api_config+: {
    data+: {
      altGreeting: "Do you wonder, why a pineapple?",
      enableRisky: "true"
    }
  },

  deployments+: {
    data+: {
      "test_wonder_qa.json": importstr 'components/deployments/wonder/test_wonder_qa.json'
    },
  },

  sealedSecret+:: import '../../components/databases/test/test_ss.json',

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