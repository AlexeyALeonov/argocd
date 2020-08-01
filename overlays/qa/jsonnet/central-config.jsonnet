function(
  apiImage="nginx",
  namespace="hello",
  namePrefix="qa-",
  nameSuffix="-central-config",
  JWT_KEY="",
  MAIN_HOSTNAME=null
)

local kube = import '../../../kube-libsonnet/kube.libsonnet';

local centralConfig = (import '../components/central-config/map.json');
local centralApiHostname = if MAIN_HOSTNAME != null then MAIN_HOSTNAME else if centralConfig.data.CENTRAL_CONFIG_API_HOSTNAME != null then centralConfig.data.CENTRAL_CONFIG_API_HOSTNAME;
local centralJwtKey = if JWT_KEY != "" then JWT_KEY else if centralConfig.data.JWT_CENTRAL_CONFIG_KEY != "" then centralConfig.data.JWT_CENTRAL_CONFIG_KEY;

local central_config = (import '../../../base/central-config.libsonnet') (
    apiImage=apiImage,
    namePrefix=namePrefix, nameSuffix=nameSuffix, namespace=namespace,
    MAIN_HOSTNAME=centralApiHostname, JWT_KEY=centralJwtKey
);

kube.List() {items_+: central_config}