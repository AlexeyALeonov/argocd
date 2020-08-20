# Install the ArgoCD with custom kustomize
## Build Kustomize from source code
```
docker build . -f Dockerfile -t kustomize:local
```
***Notes**: The current customization of ArgoCD installer will build the Kustomize in the init container*
## Load the image to the kind cluster
```
kind load docker-image kustomize:local
```
## Install/Upgrade ArgoCD
```
~/kustomize build argocd | kubectl apply -f -
```
