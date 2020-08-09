# Description
Simulates staging environments for different applications

This branch (`develop`) is specialized on [Kustomize](https://kubernetes-sigs.github.io/kustomize/) usage. [The app of apps](https://argoproj.github.io/argo-cd/operator-manual/cluster-bootstrapping/#app-of-apps-pattern) is built with Kustomize too.

The Production (`master` branch) uses the same approach. The app of apps is built with helm charts.

The QA (`qa` branch) uses the [jsonnet](https://jsonnet.org/) approach.

# Overview of layers
## ArgoCD
The ArgoCD application controller
```
.
├── argocd
│   ├── argocd-namespace.yaml
│   ├── Dockerfile
│   ├── ingress.yaml
│   ├── kustomization.yaml
│   ├── README.md
│   └── upgrade-tools.yaml
```

## Cluster
Contains components of the local cluster.
```
├── cluster
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
│   └── SealedSecrets
│       └── kustomization.yaml
```

## Configurations
The typical (almost) structure for the Kustomize applications.
```
├── base
├── components
├── overlays
```

* The **base** usually contains basic parts, which used as a base for the underlayer applications. It could be on the **overlays** level too.
* The **components** contains re-usable components, it could present on the **overlays** level too.
* The **overlays** contains layers such as *staging*, *qa*, *production* or other variants.

You can read more there: https://kubernetes-sigs.github.io/kustomize/

### Full tree of the current **staging** layer
```
├── base
│   ├── api
│   │   ├── api.yaml
│   │   ├── configMap.yaml
│   │   ├── config.yaml
│   │   ├── kustomization.yaml
│   │   ├── namespace.yaml
│   │   └── sealedsecret_databases.json
│   ├── app
│   │   ├── app.yaml
│   │   ├── config.yaml
│   │   └── kustomization.yaml
│   ├── auth
│   │   ├── api.yaml
│   │   ├── configMap.yaml
│   │   ├── config.yaml
│   │   ├── ingress.yaml
│   │   └── kustomization.yaml
│   ├── central-config
│   │   ├── api.yaml
│   │   ├── configMap.yaml
│   │   ├── config.yaml
│   │   ├── ingress.yaml
│   │   └── kustomization.yaml
│   ├── hello
│   │   └── kustomization.yaml
│   ├── nginx
│   │   ├── configMap.yaml
│   │   ├── config.yaml
│   │   ├── kustomization.yaml
│   │   └── nginx.yaml
│   ├── producer
│   │   ├── kustomization.yaml
│   │   └── producer.yaml
│   └── ui
│       ├── configMap.yaml
│       ├── config.yaml
│       ├── kustomization.yaml
│       └── ui.yaml
├── components
│   ├── auth
│   │   ├── kustomization.yaml
│   │   └── map.yaml
│   ├── central-config
│   │   ├── kustomization.yaml
│   │   └── map.yaml
│   └── databases
│       ├── test
│       │   ├── kustomization.yaml
│       │   └── test_ss.json
│       └── test3
│           ├── kustomization.yaml
│           └── test3_ss.json
├── LICENSE
├── overlays
│   └── staging
│       ├── apps
│       │   ├── auth
│       │   │   ├── auth.yaml
│       │   │   └── kustomization.yaml
│       │   ├── central-config
│       │   │   ├── central-config.yaml
│       │   │   └── kustomization.yaml
│       │   ├── hello
│       │   │   ├── hello.yaml
│       │   │   └── kustomization.yaml
│       │   ├── helm
│       │   │   ├── Chart.yaml
│       │   │   ├── templates
│       │   │   │   ├── auth.yaml
│       │   │   │   ├── central-config.yaml
│       │   │   │   ├── hello.yaml
│       │   │   │   ├── producer-test3.yaml
│       │   │   │   └── producer-test.yaml
│       │   │   └── values.yaml
│       │   ├── kustomization.yaml
│       │   ├── producer-test
│       │   │   ├── kustomization.yaml
│       │   │   └── producer-test.yaml
│       │   ├── producer-test3
│       │   │   ├── kustomization.yaml
│       │   │   └── producer-test3.yaml
│       │   ├── to-try
│       │   │   ├── kustomization.yaml
│       │   │   └── to-try.yaml
│       │   └── wonder
│       │       ├── kustomization.yaml
│       │       └── wonder.yaml
│       ├── apps.yaml
│       ├── auth
│       │   └── kustomization.yaml
│       ├── base
│       │   ├── app
│       │   │   ├── app.yaml
│       │   │   └── kustomization.yaml
│       │   ├── hello
│       │   │   └── kustomization.yaml
│       │   └── producer
│       │       └── kustomization.yaml
│       ├── central-config
│       │   └── kustomization.yaml
│       ├── components
│       │   ├── auth
│       │   │   ├── kustomization.yaml
│       │   │   └── map.yaml
│       │   ├── central-config
│       │   │   ├── kustomization.yaml
│       │   │   └── map.yaml
│       │   └── deployments
│       │       ├── hello
│       │       │   ├── kustomization.yaml
│       │       │   └── test_hello_dev.json
│       │       ├── to-try
│       │       │   ├── kustomization.yaml
│       │       │   └── test_to-try_dev.json
│       │       └── wonder
│       │           ├── kustomization.yaml
│       │           └── test3_wonder_dev.json
│       ├── hello
│       │   ├── kustomization.yaml
│       │   └── map.yaml
│       ├── producer-test
│       │   └── kustomization.yaml
│       ├── producer-test3
│       │   └── kustomization.yaml
│       ├── to-try
│       │   ├── kustomization.yaml
│       │   └── map.yaml
│       └── wonder
│           ├── kustomization.yaml
│           └── map.yaml
├── README.md
```

# How to install all staging applications
```
kubectl apply -f overlays/staging/apps.yaml
```

# How to manage configurations from the CI pipelines
To configure environments, the image in particular, we can use a different tools to do that

## Changing images in the ArgoCD base Application for environments (will affect all dependent applications)
```
yq -y '.spec.source.kustomize.images |= (. // [] | [(.[] | split("=") | {(.[0]): .[1]})] | add | .uiImage = "nginx:stable-perl" | .apiImage = "nginx" | to_entries | map(.key + "=" + .value))' overlays/staging/base/app/app.yaml > 1.yaml && mv 1.yaml overlays/staging/base/app/app.yaml
```

## Changing images in the ArgoCD Application of the environment (will affect only this one)
```
yq -y '.spec.source.kustomize.images |= (. // [] | [(.[] | split("=") | {(.[0]): .[1]})] | add | .uiImage = "nginx:stable-perl" | .apiImage = "nginx" | to_entries | map(.key + "=" + .value))' overlays/staging/apps/hello/hello.yaml > 1.yaml && mv 1.yaml overlays/staging/apps/hello/hello.yaml
```

## Changing images in the base environment (will affect all dependent)
```
pushd overlays/staging/base/hello
kustomize edit set image apiImage=nginx uiImage=nginx:stable-perl
popd
```

## Changing images in the end environment (will affect only this one)
```
pushd overlays/staging/hello
kustomize edit set image apiImage=nginx uiImage=nginx:stable-perl
popd
```
