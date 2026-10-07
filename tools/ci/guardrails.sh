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
assert permissions == ["Communications", "ComplicationPublisher"], "Companion permissions must match the transport and feed contract"
PY

for forbidden_dir in apps/watchface apps/run-data-field; do
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

"${PYTHON:-python3}" -B - <<'PYCODE'
from pathlib import Path
import xml.etree.ElementTree as ET
ns = {"iq": "http://www.garmin.com/xml/connectiq"}
provider = ET.parse("apps/audio-provider/manifest.xml")
app = provider.find("iq:application", ns)
assert app.attrib["type"] == "audio-content-provider-app"
assert app.attrib["id"] == "0a5435b5995c4c10826cc11606e31350"
assert {p.attrib["id"] for p in provider.findall(".//iq:product", ns)} == {"fenix843mm", "fenix847mm"}
assert [p.attrib["id"] for p in provider.findall(".//iq:uses-permission", ns)] == ["Communications", "ComplicationPublisher"]
assert "Copyright (c) 2026 Christian Brooker" in Path("apps/audio-provider/third-party/WATCHSHELF-LICENSE.txt").read_text()
source = "\n".join(p.read_text() for p in Path("apps/audio-provider/source").glob("*.mc") if not p.name.endswith("Tests.mc"))
assert "resetContentCache" not in source
assert "Settings.API_KEY" not in source
PYCODE
"${PYTHON:-python3}" -B tools/ci/check_transport_fixtures.py
"${PYTHON:-python3}" -B tools/ci/check_provider_fixtures.py
echo "BookWave Garmin repository guardrails PASS"
