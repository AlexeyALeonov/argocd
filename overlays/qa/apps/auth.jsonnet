function(
  namespace = "hello",
  namePrefix = "qa-",
  nameSuffix = "-auth",
  targetRevision = "qa",
  authImage = null
)

local params = import '../params.libsonnet';

(import '../../../base/app.libsonnet') (
  authImage = if authImage != null then authImage else params.authImage,
  namePrefix = namePrefix, nameSuffix = nameSuffix, namespace = namespace,
  targetRevision = targetRevision, path = 'overlays/qa/auth'
)
