# Creation of Vault
```
vault operator init
vault operator unseal
vault auth enable github
vault write auth/github/config user=cschmatzler
```

# On Vault restart
```
vault operator unseal
```
