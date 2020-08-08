function(
  namespace = "argocd",
  name = "auth",
  namePrefix = "qa-",
  nameSuffix = "-app",
  targetRevision = "qa",
  authImage = null
)

local params = import '../params.libsonnet';

(import '../../../base/app.libsonnet') (
  authImage = if authImage != null then authImage else params.authImage,
  namePrefix = namePrefix, nameSuffix = nameSuffix, namespace = namespace, name = name,
  targetRevision = targetRevision, path = 'overlays/qa/auth'
)
