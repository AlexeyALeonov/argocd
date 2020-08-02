function(
  namespace="argocd",
  name="auth"
  namePrefix="qa-",
  nameSuffix="-app",
  targetRevision="qa"
)

(import '../../../base/app.libsonnet') (
  namePrefix=namePrefix, nameSuffix=nameSuffix, namespace=namespace, name=name,
  targetRevision=targetRevision, path='overlays/qa/auth'
)
