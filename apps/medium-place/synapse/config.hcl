auto_auth {
  method "kubernetes" {
    mount_path = "auth/kubernetes"
    config = {
      role = "synapse"
    }
  }
  sink "file" {
    config = {
      path = "/vault/.vault-token"
    }
  }
}
exit_after_auth = false
template_config {
  error_on_missing_key = true
}
template {
  contents = "{{- with secret \"secret/medium-place/synapse/secret\" }}{{ .Data.data.signing_key }}{{ end }}"
  destination = "/vault/secrets/medium.place.signing.key"
}
template {
  contents = <<EOH
    server_name: medium.place

    listeners:
      - port: 8008
        tls: false
        type: http
        x_forwarded: true
        bind_addresses: ['0.0.0.0']

        resources:
          - names: [client, federation]
            compress: false

    trusted_key_servers:
      - server_name: privacytools.io

    database:
      name: psycopg2
      txn_limit: 10000
      args:
        {{- with secret "secret/medium-place/synapse/database" }}
        host: {{ .Data.data.host }}
        port: 5432
        user: {{ .Data.data.user }}
        password: {{ .Data.data.password }}
        database: {{ .Data.data.name }}
        cp_min: 5
        cp_max: 10
        {{ end }}

    media_store_path: /tmp
    max_upload_size: 50M
    media_storage_providers:
      - module: s3_storage_provider.S3StorageProviderBackend
        store_local: true
        store_remote: true
        store_synchronous: true
        config:
          {{- with secret "secret/medium-place/synapse/s3" }}
          bucket: {{ .Data.data.bucket }}
          region_name: {{ .Data.data.region }}
          endpoint_url: {{ .Data.data.endpoint }}
          access_key_id: {{ .Data.data.access_key }}
          secret_access_key: {{ .Data.data.secret_key }}
          {{ end }}

    {{- with secret "secret/medium-place/synapse/secret" }}
    turn_uris:
      - turn:turn.medium.place:3478?transport=udp
    turn_shared_secret: {{ .Data.data.turn_key }}
    turn_allow_guests: false
    {{ end }}

    email:
      {{- with secret "secret/external/mail" }}
      smtp_host: {{ .Data.data.host }}
      smtp_port: 587
      require_transport_security: true
      smtp_user: {{ .Data.data.user }}
      smtp_pass: {{ .Data.data.password }}
      notif_from: "Your Friendly %(app)s homeserver <services@leuchtturm.io>"
      {{ end }}

    {{- with secret "secret/medium-place/synapse/secret" }}
    enable_registration: true
    registration_requires_token: true
    registration_shared_secret: {{ .Data.data.registration_key }}
    macaroon_secret_key: {{ .Data.data.macaroon_key }}
    {{ end }}

    push:
      include_content: false

    report_stats: true
  EOH
  destination = "/vault/secrets/homeserver.yaml"
}