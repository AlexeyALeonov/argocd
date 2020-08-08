function(
  name = "hello",
  namePrefix = "",
  nameSuffix = "",
  namespace = "hello",
  targetRevision = null,
  path = null,
  apiImage = null,
  uiImage = null,
  nginxImage = null,
  producerImage = null,
  authImage = null,
  centralConfigImage = null
)

local kube = import '../kube-libsonnet/kube.libsonnet';

{
  "apiVersion": "argoproj.io/v1alpha1",
  "kind": "Application",
  "metadata": {
    "name": namePrefix + name + nameSuffix,
    "namespace": "argocd",
    "finalizers": [
      "resources-finalizer.argocd.argoproj.io"
    ]
  },
  "spec": {
    "project": "default",
    "source": {
      "repoURL": "https://github.com/AlexeyALeonov/argocd.git",
      [if targetRevision != null then "targetRevision"]: targetRevision,
      [if path != null then "path"]: path,
      directory: {
        jsonnet: {
          tlas_:: {
            [if apiImage != null then "apiImage"]: {
              code: false,
              value: apiImage
            },
            [if uiImage != null then "uiImage"]: {
              code: false,
              value: uiImage
            },
            [if nginxImage != null then "nginxImage"]: {
              code: false,
              value: nginxImage
            },
            [if producerImage != null then "producerImage"]: {
              code: false,
              value: producerImage
            },
            [if authImage != null then "authImage"]: {
              code: false,
              value: authImage
            },
            [if centralConfigImage != null then "centralConfigImage"]: {
              code: false,
              value: centralConfigImage
            },
          },
          tlas: kube.mapToNamedList(self.tlas_),
        }
      },
    },
    "destination": {
      "server": "https://kubernetes.default.svc",
      "namespace": namePrefix + namespace + nameSuffix
    },
    "syncPolicy": {
      "automated": {
        "prune": true,
        "selfHeal": true
      }
    }
  }
}
