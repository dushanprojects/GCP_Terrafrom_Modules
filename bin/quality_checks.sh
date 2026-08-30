#!/usr/bin/env bash
# Runs the same checks as the CI workflow, so a change can be checked before
# it is pushed. No GCP credentials are needed and nothing is created
set -uo pipefail

cd "$(dirname "$0")/.." || exit 1
status=0

echo "==> Format"
terraform fmt -check -recursive -diff || status=1

echo "==> Validate"
for dir in $(find modules examples -name "*.tf" -exec dirname {} \; | sort -u); do
  terraform -chdir="${dir}" init -backend=false -input=false >/dev/null 2>&1 || { echo "init failed: ${dir}"; status=1; continue; }
  terraform -chdir="${dir}" validate || status=1
done

echo "==> Test"
for dir in $(find modules -type d -name tests | sort); do
  module=$(dirname "${dir}")
  echo "--- ${module}"
  terraform -chdir="${module}" init -backend=false -input=false >/dev/null 2>&1
  terraform -chdir="${module}" test || status=1
done

echo "==> Lint"
if command -v tflint >/dev/null 2>&1; then
  tflint --init >/dev/null 2>&1
  tflint --recursive --config "$(pwd)/.tflint.hcl" --format compact || status=1
else
  echo "tflint is not installed, skipping"
fi

echo "==> Security scan"
# Trivy tries to download the current checks from ghcr.io first. When that is
# rate limited it falls back to the checks built into the binary, which are
# older, so a local result can differ from the CI result. Add
# --skip-check-update to always use the built in checks
if command -v trivy >/dev/null 2>&1; then
  trivy config . || status=1
else
  echo "trivy is not installed, skipping"
fi

if command -v checkov >/dev/null 2>&1; then
  # Compares against the baseline, so only new findings fail, the same as CI does
  checkov --directory . --framework terraform --quiet --compact --baseline .checkov.baseline || status=1
else
  echo "checkov is not installed, skipping"
fi

exit $status
