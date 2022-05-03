# Creation of Vault
```
vault auth enable github
vault write auth/github/config organization=leuchtturm-io
vault write auth/github/map/users/cschmatzler value=allow_all
```
