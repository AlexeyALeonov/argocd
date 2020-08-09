function(
  namespace = "hello",
  namePrefix = "qa-",
  nameSuffix = "-central-config",
  targetRevision = "qa",
  centralConfigImage = null
)

local params = import '../params.libsonnet';

(import '../../../base/app.libsonnet') (
  centralConfigImage = if centralConfigImage != null then centralConfigImage else params.centralConfigImage,
  namePrefix = namePrefix, nameSuffix = nameSuffix, namespace = namespace,
  targetRevision = targetRevision, path = 'overlays/qa/central-config'
)
