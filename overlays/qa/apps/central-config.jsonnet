function(
  namespace="argocd",
  name="central-config"
  namePrefix="qa-",
  nameSuffix="-app",
  targetRevision="qa"
)

(import '../../../base/app.libsonnet') (
  namePrefix=namePrefix, nameSuffix=nameSuffix, namespace=namespace, name=name,
  targetRevision=targetRevision, path='overlays/qa/central-config'
)
