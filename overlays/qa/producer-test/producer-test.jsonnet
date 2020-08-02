function(
  apiImage="nginx",
  namespace="hello",
  namePrefix="qa-",
  nameSuffix="-producer-test"
)

local kube = import '../../../kube-libsonnet/kube.libsonnet';

local producer_test = (import '../../../base/producer.libsonnet') (
  apiImage=apiImage, 
  namePrefix=namePrefix, nameSuffix=nameSuffix, namespace=namespace
)
{
  deployments+: {
    data+: {
      "test_simple_qa.json": importstr '../components/deployments/simple/test_simple_qa.json',
      "test_wonder_qa.json": importstr '../components/deployments/wonder/test_wonder_qa.json'
    },
  },

  local databases = import '../../../components/databases/test/test_ss.json',

  databases+: databases + super.databases_name,
};

kube.List() {items_+: producer_test}