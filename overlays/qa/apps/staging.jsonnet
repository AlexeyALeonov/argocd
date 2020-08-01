function(
  namespace="hello",
  namePrefix="qa-",
  nameSuffix="-jsonnet",
  targetRevision="qa"
)

(import '../../../base/app.libsonnet') (
  namePrefix=namePrefix, nameSuffix=nameSuffix, namespace=namespace,
  targetRevision=targetRevision, path='overlays/qa/jsonnet'
)
{
  spec+: {
    source+: {
      directory+: {
        recurse: true
      },
    },
    destination+: {
      namespace:: super.namespace
    },
  }
}
