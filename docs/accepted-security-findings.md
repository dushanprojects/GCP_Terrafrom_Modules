<!--
Kept out of the main README on purpose. This is a working record for the
maintainers of this repository, not documentation for the modules themselves.
-->

# Accepted security findings

Checkov and Trivy both fail the build on any finding. Two Checkov checks cannot
be satisfied. Each is skipped in the code next to the resource it applies to,
with the reason written in the skip. There are no Trivy suppressions.

| Check      | Where                             | Why it cannot be fixed                                                                                                        |
|------------|-----------------------------------|-----------------------------------------------------------------------------------------------------------------------------------|
| CKV_GCP_6  | `db_mysql/main.tf`                | The check looks for `require_ssl`, which Google removed from the provider in version 7. The module sets its replacement, `ssl_mode = "ENCRYPTED_ONLY"`. Checkov 3.3.15 still does not read `ssl_mode`, confirmed against a literal instance with no variables. Trivy accepts it since January 2026 |
| CKV_GCP_12 | `gke_regional_cluster/cluster.tf` | The check looks for the Calico network policy add on. The cluster runs Dataplane V2, which enforces network policy itself and refuses to run alongside the add on |

Remove the CKV_GCP_6 skip once Checkov reads `ssl_mode`.

## A note on running Trivy locally

Trivy fetches its checks from ghcr.io and falls back to the checks built into
the binary when that fails. An old binary therefore reports findings that CI
does not. Trivy 0.53.0 reports `AVD-GCP-0015` against `db_mysql`, because its
built in checks predate the January 2026 change that accepts `ssl_mode`. Keep
the local binary current, and treat the CI result as the real one.
