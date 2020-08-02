function(
  namespace="argocd",
  name="wonder"
  namePrefix="qa-",
  nameSuffix="-app",
  targetRevision="qa"
)

(import '../../../base/app.libsonnet') (
  namePrefix=namePrefix, nameSuffix=nameSuffix, namespace=namespace, name=name,
  targetRevision=targetRevision, path='overlays/qa/wonder'
)
