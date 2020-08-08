function(
  namespace = "argocd",
  name = "producer-test",
  namePrefix = "qa-",
  nameSuffix = "-app",
  targetRevision = "qa",
  producerImage = null
)

local params = import '../params.libsonnet';

(import '../../../base/app.libsonnet') (
  producerImage = if producerImage != null then producerImage else params.producerImage,
  namePrefix = namePrefix, nameSuffix = nameSuffix, namespace = namespace, name = name,
  targetRevision = targetRevision, path = 'overlays/qa/producer-test'
)
