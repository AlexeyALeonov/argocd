function(
  apiImage="nginx",
  namespace="hello",
  namePrefix="staging-",
  nameSuffix="-producer"
)

local kube = import '../../../kube-libsonnet/kube.libsonnet';

local producer_test3 = (import '../../../base/producer.libsonnet') (
  apiImage=apiImage, 
  namePrefix=namePrefix, nameSuffix=nameSuffix, namespace=namespace
)
{
  deployments+: {
    data+: {
      "test3_simple_dev.json": importstr '../components/deployments/simple/test3_simple_dev.json',
      "test3_wonder_dev.json": importstr '../components/deployments/wonder/test3_wonder_dev.json'
    },
  },

  local databases = import '../../../components/databases/test3/test3_ss.json',

  databases+: {
    spec+: {
      encryptedData+: databases.spec.encryptedData
    },
  },
};

kube.List() {items_+: producer_test3}