function(
  producerImage = "nginx",
  namespace = "hello",
  namePrefix = "qa-",
  nameSuffix = "-producer-test"
)

local kube = import '../../../kube-libsonnet/kube.libsonnet';

local producer_test = (import '../../../base/producer.libsonnet') (
  producerImage = producerImage, 
  namePrefix = namePrefix, nameSuffix = nameSuffix, namespace = namespace
)
{
  deployments+: {
    data+: {
      "test_simple_qa.json": importstr '../components/deployments/simple/test_simple_qa.json',
      "test_wonder_qa.json": importstr '../components/deployments/wonder/test_wonder_qa.json'
    },
  },

  sealedSecret+:: import '../../../components/databases/test/test_ss.json',
};

kube.List() {items_+: producer_test}