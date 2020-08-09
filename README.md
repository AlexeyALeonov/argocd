# argocd
to test the ArgoCD

## Purpose of this branch
It's simulate a QA staging with own configs and own environments.

Unlike Production (`master`) or `develop`, this branch (`qa`) uses solely jsonnet approach.

## Configuarions
Since it's a jsonnet, you can configure directly in the jsonnet files or use the `params.libsonnet` file in the `overlays/qa`.

### Using `params.libsonnet`
It's specifically designed as a `json` file to allow you to modify it with a `jq` processor.

For example,

```
jq '.apiImage = "api-image:92bb07d7d06a3de7fa91a916173513e1135f6b24"' overlays/qa/params.libsonnet > 1.json && mv 1.json overlays/qa/params.libsonnet
```

### Directly modify the requiered config
#### From a CLI

```
sed -i 's/apiImage = ".*",/apiImage = "api-image:92bb07d7d06a3de7fa91a916173513e1135f6b24",/g' overlays/qa/simple/simple.jsonnet
```

#### From the editor
Open a file and replace the required parameter, save it.

## Auto deploy
Automatic deployment will happen to the configured cluster after every commit on the branch.

Since the cluster is not published, the time between commit and actual start of deploy can vary.