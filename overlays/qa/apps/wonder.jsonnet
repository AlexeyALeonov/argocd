function(
  namespace="argocd",
  name="wonder",
  namePrefix="qa-",
  nameSuffix="-app",
  targetRevision="qa"
)

(import '../../../base/app.libsonnet') (
  namePrefix=namePrefix, nameSuffix=nameSuffix, namespace=namespace, name=name,
  targetRevision=targetRevision, path='overlays/qa/wonder'
)
{
  spec+: {
    source+: {
      directory+: {
        jsonnet+: {
          tlas: [
            {
              code: false,
              name: "apiImage",
              value: "nginx:stable-perl"
            },
          ],
        },
      },
    },
  },
}
