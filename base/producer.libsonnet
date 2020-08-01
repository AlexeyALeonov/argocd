function(
  apiImage="nginx",
  namespace="hello",
  namePrefix="",
  nameSuffix="-producer"
)

(import 'api.libsonnet') (
  apiImage=apiImage, 
  namePrefix=namePrefix, nameSuffix=nameSuffix, namespace=namespace
)
{
  api_ing:: super.api_ing
}
