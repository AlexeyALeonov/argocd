function(
  authImage = "nginx",
  namespace = "hello",
  namePrefix = "qa-",
  nameSuffix = "-auth",
  JWT_KEY = "",
  CENTRAL_CONFIG_API_URL = null,
  JWT_CENTRAL_CONFIG_KEY = "",
  MAIN_HOSTNAME = null
)

local kube = import '../../../kube-libsonnet/kube.libsonnet';

local centralConfig = (import '../components/central-config/map.json');
local centralApiUrl = if CENTRAL_CONFIG_API_URL != null then CENTRAL_CONFIG_API_URL else if centralConfig.data.CENTRAL_CONFIG_API_HOSTNAME != null then "http://" + centralConfig.data.CENTRAL_CONFIG_API_HOSTNAME;
local centralJwtKey = if JWT_CENTRAL_CONFIG_KEY != "" then JWT_CENTRAL_CONFIG_KEY else if centralConfig.data.JWT_CENTRAL_CONFIG_KEY != "" then centralConfig.data.JWT_CENTRAL_CONFIG_KEY;

local authConfig = (import '../components/auth/map.json');
local authApiHostname = if MAIN_HOSTNAME != null then MAIN_HOSTNAME else if authConfig.data.AUTH_API_HOSTNAME != null then authConfig.data.AUTH_API_HOSTNAME;
local authJwtKey = if JWT_KEY != "" then JWT_KEY else if authConfig.data.JWT_AUTH_KEY != "" then authConfig.data.JWT_AUTH_KEY;

local auth = (import '../../../base/auth.libsonnet') (
  authImage = authImage,
  namePrefix = namePrefix, nameSuffix = nameSuffix, namespace = namespace,
  MAIN_HOSTNAME = authApiHostname, JWT_KEY = authJwtKey,
  CENTRAL_CONFIG_API_URL = centralApiUrl, JWT_CENTRAL_CONFIG_KEY = centralJwtKey
);

kube.List() {items_+: auth}