# Install the ArgoCD with custom kustomize
## Build kustomize from source code
```
docker build argocd\ -f argocd\Dockerfile.kustomize -t kustomize:local
```
## Load the image to the kind cluster
```
kind load docker-image kustomize:local
```
## Install ArgoCD
```
~/kustomize build argocd | kubectl apply -f -
```
