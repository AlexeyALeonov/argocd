function(
  authImage = "nginx",
  namespace = "hello",
  namePrefix = "qa-",
  nameSuffix = "-auth",
  JWT_KEY = null,
  CENTRAL_CONFIG_API_URL = null,
  JWT_CENTRAL_CONFIG_KEY = null,
  MAIN_HOSTNAME = null
)

local kube = import '../../../kube-libsonnet/kube.libsonnet';

local auth = (import '../../../base/auth.libsonnet') (
  authImage = authImage,
  namePrefix = namePrefix, nameSuffix = nameSuffix, namespace = namespace,
  MAIN_HOSTNAME = MAIN_HOSTNAME, JWT_KEY = JWT_KEY,
  CENTRAL_CONFIG_API_URL = CENTRAL_CONFIG_API_URL, JWT_CENTRAL_CONFIG_KEY = JWT_CENTRAL_CONFIG_KEY
)
{
  centralConfig:: (import '../components/central-config/map.json'),
  authConfig:: (import '../components/auth/map.json'),
};

kube.List() {items_+: auth}