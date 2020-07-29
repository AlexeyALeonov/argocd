# Description
This is customized kubernetes-dashboard with skip login enabled and granted admin rights to the service account

## To install
```
helm dependency update .
helm install kubernetes-dashboard . --namespace kubernetes-dashboard --create-namespace
```

## To access the dashboard
https://github.com/kubernetes/dashboard/tree/master/docs/user/accessing-dashboard#kubectl-port-forward

Also, you can expose the dashboard via [ingress controller](../nginx-ingress-controller/README.md) (the default, see [values.yaml](./values.yaml))

## Access rights
### Service role
Use the "Skip" button on the dashboard

### Separate account
If you want to create a separate admin role: https://github.com/kubernetes/dashboard/blob/master/docs/user/access-control/creating-sample-user.md

#### Windows PowerShell

To receive a Bearer token to login:
```
kubectl -n default describe secret $(kubectl get secret | sls admin-user-token | ForEach-Object { $_ -Split '\s+' } | Select -First 1)
```