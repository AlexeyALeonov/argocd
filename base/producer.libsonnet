function(
  producerImage = "nginx",
  namespace = "hello",
  namePrefix = "",
  nameSuffix = "-producer"
)

(import 'api.libsonnet') (
  apiImage = producerImage, 
  namePrefix = namePrefix, nameSuffix = nameSuffix, namespace = namespace
)
{
  api_ing:: super.api_ing
}
