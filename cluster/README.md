# Cluster
Contains components of the local cluster.

```
├── cluster
```

## Kind cluster
See [kind](https://kind.sigs.k8s.io/)
```
│   ├── kind
│   │   ├── kind-cluster.yaml
│   │   ├── kubernetes-dashboard
│   │   │   ├── Chart.yaml
│   │   │   ├── README.md
│   │   │   ├── requirements.lock
│   │   │   ├── requirements.yaml
│   │   │   ├── templates
│   │   │   │   └── kubernetes-admin.yaml
│   │   │   └── values.yaml
│   │   └── nginx-ingress-controller
│   │       ├── configMap.yaml
│   │       ├── kustomization.yaml
│   │       └── README.md
```

### Installation
1. Install Kubernetes **kind** cluster
```
kind create --config kind/kind-cluster.yaml
```
2. Install [NGINX Ingress Controller](cluster/kind/nginx-ingress-controller/README.md)
3. Install [Kubernetes Dashboard](cluster/kind/kubernetes-dashboard/README.md)
4. Install [kube-ops-view](https://github.com/helm/charts/tree/master/stable/kube-ops-view)
```
helm upgrade kube-ops-view -i stable/kube-ops-view --set ingress.enabled=true,rbac.create=true --namespace default
```

## The ArgoCD application controller
[Argo CD](https://argoproj.github.io/argo-cd/)
```
│   ├── argocd
│   │   ├── argocd-namespace.yaml
│   │   ├── Dockerfile
│   │   ├── ingress.yaml
│   │   ├── kustomization.yaml
│   │   ├── README.md
│   │   └── upgrade-tools.yaml
```

### Installation
```
kustomize build argocd | kubectl apply -f -
```
See [README for details](argocd/README.md)

## The Argo Rollouts application controller
[Argo Rollouts](https://argoproj.github.io/argo-rollouts/)
```
│   ├── argo-rollouts
│   │   ├── kustomization.yaml
│   │   └── namespace.yaml
```

### Installation
```
kustomize build argo-rollouts | kubectl apply -f -
```

## Reloader
The [Reloader](https://github.com/stakater/Reloader) controller allows the rolling update of deployment when related ConfigMap/Secret have been updated
```
│   ├── reloader
│   │   ├── kustomization.yaml
│   │   └── namespace.yaml
```

### Installation
```
kustomize build reloader | kubectl apply -f -
```

## SealedSecrets
The [SealedSecrets](https://github.com/bitnami-labs/sealed-secrets) controller allows deploy the encrypted secrets to the cluster
```
│   └── SealedSecrets
│       └── kustomization.yaml
```
### Installation
```
kustomize build SealedSecrets | kubectl apply -f -
```
