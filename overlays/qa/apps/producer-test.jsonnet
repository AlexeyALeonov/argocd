function(
  namespace = "hello",
  namePrefix = "qa-",
  nameSuffix = "-producer-test",
  targetRevision = "qa",
  producerImage = null
)

local params = import '../params.libsonnet';

(import '../../../base/app.libsonnet') (
  producerImage = if producerImage != null then producerImage else params.producerImage,
  namePrefix = namePrefix, nameSuffix = nameSuffix, namespace = namespace,
  targetRevision = targetRevision, path = 'overlays/qa/producer-test'
)
