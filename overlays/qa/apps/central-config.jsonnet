function(
  namespace = "argocd",
  name = "central-config",
  namePrefix = "qa-",
  nameSuffix = "-app",
  targetRevision = "qa",
  centralConfigImage = null
)

local params = import '../params.libsonnet';

(import '../../../base/app.libsonnet') (
  centralConfigImage = if centralConfigImage != null then centralConfigImage else params.centralConfigImage,
  namePrefix = namePrefix, nameSuffix = nameSuffix, namespace = namespace, name = name,
  targetRevision = targetRevision, path = 'overlays/qa/central-config'
)
