function(
  name="hello",
  namePrefix="",
  nameSuffix="",
  namespace="hello",
  targetRevision=null,
  path=null
)
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
