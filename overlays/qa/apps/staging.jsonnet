function(
  namespace="hello",
  namePrefix="staging-",
  nameSuffix="-jsonnet",
  targetRevision="feature/add-jsonnet-version"
)

(import '../../../../base/app.libsonnet') (
  namePrefix=namePrefix, nameSuffix=nameSuffix, namespace=namespace,
  targetRevision=targetRevision, path='overlays/staging/jsonnet'
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
