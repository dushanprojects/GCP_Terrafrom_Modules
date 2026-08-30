<!--
Kept out of the main README on purpose. This is a working record for the
maintainers of this repository, not documentation for the modules themselves.
-->

# Accepted security findings

Checkov and Trivy both fail the build on any finding. Three checks cannot be
satisfied, and each one is skipped in the code next to the resource it applies
to, with the reason written in the skip.

| Check                   | Where                              | Why it cannot be fixed                                                                                                                |
|-------------------------|------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------|
| CKV_GCP_6, AVD-GCP-0015 | `db_mysql/main.tf`                 | The check asks for `require_ssl`. Google removed that argument from the provider in version 7, so it cannot be set. The module sets its replacement, `ssl_mode = "ENCRYPTED_ONLY"` |
| CKV_GCP_12              | `gke_regional_cluster/cluster.tf`  | The check asks for the Calico network policy add on. The cluster runs Dataplane V2, which enforces network policy itself and refuses to run alongside the add on |
| AVD-GCP-0048            | `gke_regional_cluster` node pools  | Both node pools and the default node pool set `disable-legacy-endpoints`. Checkov reads the same setting and passes, so this is a limitation of how the check reads the metadata map |

The Trivy entries live in `.trivyignore.yaml` with a review date, because Trivy
has no inline skip that survives its module resolution. The Checkov entries are
`# checkov:skip=` comments in the module source.

There is no baseline file. Everything else that the scanners reported has been
fixed rather than suppressed.
