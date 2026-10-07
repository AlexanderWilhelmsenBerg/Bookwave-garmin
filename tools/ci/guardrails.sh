#!/usr/bin/env bash
set -euo pipefail

manifest="apps/companion/manifest.xml"

fail() {
  echo "::error::$1"
  exit 1
}

[[ -f "$manifest" ]] || fail "Companion manifest is missing."

grep -q 'type="watch-app"' "$manifest" \
  || fail "Companion Companion must remain a normal Connect IQ Device App (watch-app)."

grep -q '<iq:product id="fenix843mm"' "$manifest" \
  || fail "fenix843mm target is missing from the Companion manifest."

grep -q '<iq:product id="fenix847mm"' "$manifest" \
  || fail "fenix847mm target is missing from the Companion manifest."

"${PYTHON:-python3}" -B - <<'PY'
import xml.etree.ElementTree as ET
ns = {"iq": "http://www.garmin.com/xml/connectiq"}
manifest = ET.parse("apps/companion/manifest.xml")
permissions = [item.attrib.get("id") for item in manifest.findall(".//iq:uses-permission", ns)]
assert permissions == ["Communications"], "Only the Phase 2 phone transport permission is allowed"
PY

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

"${PYTHON:-python3}" -B tools/ci/check_transport_fixtures.py
echo "Companion repository guardrails PASS"
