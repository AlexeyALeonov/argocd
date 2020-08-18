# Description
Simulates Production environment

This branch (`master`) is specialized on [Kustomize](https://kubernetes-sigs.github.io/kustomize/) usage. [The app of apps](https://argoproj.github.io/argo-cd/operator-manual/cluster-bootstrapping/#app-of-apps-pattern) is built with [Helm](https://helm.sh/).

The Staging (`develop` branch) uses the same approach. The app of apps built with Kustomize too.

The QA (`qa` branch) uses the [jsonnet](https://jsonnet.org/) approach.

# Overview of layers
The idea is using layers to reach the [DRY](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself) principle.

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

### Some differences from Staging
Usually each service should run in own namespace. In the current implementation we uses the [SealedSecrets](https://github.com/bitnami-labs/sealed-secrets) to store secret information in the Git without risk to expose it in the public network - all passwords are encrypted with a key, unique for the destination cluster (for the deployment of SealedSecrets controller to be precise).

The SealedSecret have an integrated ability to strict the access with different level of limitations: https://github.com/bitnami-labs/sealed-secrets#scopes

In the Staging environments we uses a cluster-wide SealedSecrets, this is mean that neither name nor namespace are checked, so it could be decrypted in the target cluster in any namespace and even if the SealedSecret will have a different name rather than encrypted.

In the Production environment we uses a strict SealedSecrets, this is mean that such secrets can be decrypted in the target cluster only if they have the same names and namespaces on time of creation.
This leads to a interesting problem: even if we would have the same credentials for all databases, we still need to create a unique SealedSecret for each unique namespace and name.

In particular, we have an API, which is connected to the several databases hosted on a different database servers and it need to have credentials to access them. SealedSecrets for those databases are created with own names but in the same namespace as the API.

Also we have two producers, each for own database server, and they need the same credentials too.
So, since we have a strict SealedSecrets, and decrypted secrets could be accessible only within the same namespace, we forced to deploy those producers to the same namespace as the API.

The other way around is to create an own SealedSecrets for each producer. They will have the same content of the secret in the cluster, but different SealedSecrets in the repo.

### Full tree
```
.
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
│   └── central-config
│       ├── kustomization.yaml
│       └── map.yaml
├── LICENSE
├── overlays
│   └── production
│       ├── apps
│       │   ├── Chart.yaml
│       │   ├── templates
│       │   │   ├── auth.yaml
│       │   │   ├── central-config.yaml
│       │   │   ├── hello.yaml
│       │   │   ├── producer-large-db1.yaml
│       │   │   └── producer-large-db2.yaml
│       │   └── values.yaml
│       ├── apps.yaml
│       ├── auth
│       │   └── kustomization.yaml
│       ├── base
│       │   └── producer
│       │       ├── kustomization.yaml
│       │       ├── removeNamespace.yaml
│       │       └── reuseSecrets.yaml
│       ├── central-config
│       │   └── kustomization.yaml
│       ├── components
│       │   └── deployments
│       │       ├── customer1
│       │       │   ├── customer1.json
│       │       │   └── kustomization.yaml
│       │       └── customer2
│       │           ├── customer2.json
│       │           └── kustomization.yaml
│       ├── hello
│       │   ├── config.yaml
│       │   ├── deployment.yaml
│       │   ├── kustomization.yaml
│       │   ├── large-db1_ss.json
│       │   └── large-db2_ss.json
│       ├── producer-large-db1
│       │   └── kustomization.yaml
│       └── producer-large-db2
│           └── kustomization.yaml
├── README.md
```

# How to install all production applications
```
kubectl apply -f overlays/production/apps.yaml
```

# How to manage configurations from the CI pipelines
To configure environments, the image in particular, we can use a different tools to do that.

Since it's a `master` branch, it's protected from direct commits. To be able to deploy the application, you should make a pull request.
The project manager will merge this PR if all versions are ready.

The ArgoCD has an ability to sync changes in a [scheduled time windows](https://argoproj.github.io/argo-cd/user-guide/sync_windows/), so the merged changes will be applied when it would not hurt customers.

## Changing images in the ArgoCD base Application for environments (will affect all dependent applications)
```
yq -y '.spec.source.app.images |= (. // [] | [(.[] | split("=") | {(.[0]): .[1]})] | add | .uiImage = "nginx:stable-perl" | .apiImage = "nginx" | to_entries | map(.key + "=" + .value))' overlays/production/apps/values.yaml > 1.yaml && mv 1.yaml overlays/production/apps/values.yaml
```

## Changing images in the base environment (will affect all dependent)
```
pushd overlays/production/base/producer
kustomize edit set image producerImage=nginx
popd
```

## Changing images in the end environment (will affect only this one)
```
# to remove the image override from the base customization
pushd overlays/production/base/producer
kustomize edit set image producerImage=producerImage
popd

pushd overlays/production/producer
kustomize edit set image producerImage=nginx
popd
```

or
```
# let's set the image in the base
pushd overlays/production/base/producer
kustomize edit set image producerImage=producer:1.3.5
popd

# replace the image from the base to a different one
pushd overlays/production/producer
kustomize edit set image producer:1.3.5=nginx:stable-perl
popd
```