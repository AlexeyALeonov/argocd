function(
  centralConfigImage = "nginx",
  namespace = "hello",
  namePrefix = "qa-",
  nameSuffix = "-central-config",
  JWT_KEY = "",
  MAIN_HOSTNAME = null
)

local kube = import '../../kube-libsonnet/kube.libsonnet';

local centralConfig = (import 'components/central-config/map.json');
local centralApiHostname = if MAIN_HOSTNAME != null then MAIN_HOSTNAME else centralConfig.data.CENTRAL_CONFIG_API_HOSTNAME;
local centralJwtKey = if JWT_KEY != "" then JWT_KEY else centralConfig.data.JWT_CENTRAL_CONFIG_KEY;

local central_config = (import '../../base/central-config.libsonnet') (
  centralConfigImage = centralConfigImage,
  namePrefix = namePrefix, nameSuffix = nameSuffix, namespace = namespace,
  MAIN_HOSTNAME = centralApiHostname, JWT_KEY = centralJwtKey
);

kube.List() {items_+: central_config}