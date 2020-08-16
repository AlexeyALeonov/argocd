function(
  centralConfigImage = "nginx",
  namespace = "hello",
  namePrefix = "qa-",
  nameSuffix = "-central-config",
  JWT_KEY = null,
  MAIN_HOSTNAME = null
)

local kube = import '../../../kube-libsonnet/kube.libsonnet';

local central_config = (import '../../../base/central-config.libsonnet') (
  centralConfigImage = centralConfigImage,
  namePrefix = namePrefix, nameSuffix = nameSuffix, namespace = namespace,
  MAIN_HOSTNAME = MAIN_HOSTNAME, JWT_KEY = JWT_KEY
)
{
  centralConfig:: (import '../components/central-config/map.json'),
};

kube.List() {items_+: central_config}