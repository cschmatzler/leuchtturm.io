# Creation of Vault
```
vault operator init
vault operator unseal
vault secrets enable kv
vault auth enable github
vault write auth/github/config user=cschmatzler

HOST=$(kubectl exec vault-0 -n vault -- printenv | grep KUBERNETES_PORT_443_TCP_ADDR | cut -f 2- -d "=" | tr -d " ")
CACERT=$(kubectl config view --raw --minify --flatten -o jsonpath='{.clusters[].cluster.certificate-authority-data}' | base64 --decode)
SECRET_NAME=$(kubectl get serviceaccount vault -n vault -o go-template='{{ (index .secrets 0).name }}')
ACCOUNT_TOKEN=$(kubectl get secret ${SECRET_NAME} -n vault -o go-template='{{ .data.token }}' | base64 --decode)
vault write auth/kubernetes/config token_reviewer_jwt="${ACCOUNT_TOKEN}" kubernetes_host="https://${HOST}:443" kubernetes_ca_cert="${CACERT}"

vault policy write read -<<EOF
path "kv/*"
{
  capabilities = ["read"]
}
EOF
```

# On Vault restart
```
vault operator unseal
```
