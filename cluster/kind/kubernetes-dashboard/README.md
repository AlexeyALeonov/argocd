## Windows PowerShell
To receive a Bearer token to login:
```
kubectl -n default describe secret $(kubectl get secret | sls admin-user-token | ForEach-Object { $_ -Split '\s+' } | Select -First 1)
```