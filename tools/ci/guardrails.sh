#!/usr/bin/env bash
set -euo pipefail

manifest="apps/companion/manifest.xml"

fail() {
  echo "::error::$1"
  exit 1
}

[[ -f "$manifest" ]] || fail "Companion manifest is missing."

grep -q 'type="watch-app"' "$manifest" \
  || fail "Phase 1 Companion must remain a normal Connect IQ Device App (watch-app)."

grep -q '<iq:product id="fenix843mm"' "$manifest" \
  || fail "fenix843mm target is missing from the Phase 1 manifest."

grep -q '<iq:product id="fenix847mm"' "$manifest" \
  || fail "fenix847mm target is missing from the Phase 1 manifest."

if grep -q '<iq:uses-permission' "$manifest"; then
  fail "Phase 1 must not request Garmin permissions; transport/network features are out of scope."
fi

for forbidden_dir in apps/watchface apps/run-data-field apps/audio-provider; do
  if [[ -e "$forbidden_dir" ]]; then
    fail "Out-of-scope production surface exists: $forbidden_dir"
  fi
done

if find apps shared -type f \( -name '*.kt' -o -name '*.java' -o -name '*.gradle' -o -name '*.gradle.kts' \) -print -quit | grep -q .; then
  fail "Android/JVM production source must not be implemented in the Garmin repository."
fi

if grep -RInE --include='*.mc' \
  '(ABS_(ACCESS|REFRESH)_TOKEN|accessToken|refreshToken|audiobookshelfPassword|serverPassword)' \
  apps shared; then
  fail "Potential credential-bearing field found in Garmin source."
fi

echo "Phase 1 repository guardrails PASS"
