function(
  namespace="argocd",
  namePrefix="",
  nameSuffix="",
  targetRevision="qa"
)

(import '../../../base/app.libsonnet') (
  namePrefix=namePrefix, nameSuffix=nameSuffix, namespace=namespace,
  targetRevision=targetRevision, path='overlays/qa/auth'
)
