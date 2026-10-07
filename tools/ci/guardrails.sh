#!/usr/bin/env bash
set -euo pipefail

manifest="apps/companion/manifest.xml"

fail() {
  echo "::error::$1"
  exit 1
}

[[ -f "$manifest" ]] || fail "Companion manifest is missing."

grep -q 'type="watch-app"' "$manifest"   || fail "Companion must remain a normal Connect IQ Device App (watch-app)."

grep -q '<iq:product id="fenix843mm"' "$manifest"   || fail "fenix843mm target is missing from the manifest."

grep -q '<iq:product id="fenix847mm"' "$manifest"   || fail "fenix847mm target is missing from the manifest."

grep -q '<iq:uses-permission id="Communications"' "$manifest"   || fail "Phase 2 requires the Garmin Communications permission."

grep -q '<iq:uses-permission id="Background"' "$manifest"   || fail "Phase 2 requires Background permission for phone-message delivery while the UI is closed."

permission_count="$(grep -c '<iq:uses-permission' "$manifest" || true)"
[[ "$permission_count" -eq 2 ]]   || fail "Phase 2 Companion should request only Communications and Background permissions."

grep -q 'registerForPhoneAppMessageEvent' apps/companion/source/BookWaveCompanionApp.mc   || fail "Background phone-message registration is missing."

grep -q 'onPhoneAppMessage' apps/companion/source/BookWaveServiceDelegate.mc   || fail "Background phone-message delegate is missing."

grep -q 'registerForPhoneAppMessages' apps/companion/source/BookWaveCompanionApp.mc   || fail "Foreground phone-message callback is missing."

grep -q 'SnapshotCodec' shared/protocol/TransportProcessor.mc   || fail "Transport must continue through the existing snapshot validation path."

grep -q 'SnapshotStore' shared/protocol/TransportProcessor.mc   || fail "Transport must continue through the existing snapshot persistence path."

for forbidden_dir in apps/watchface apps/run-data-field apps/audio-provider; do
  if [[ -e "$forbidden_dir" ]]; then
    fail "Out-of-scope production surface exists: $forbidden_dir"
  fi
done

if find apps shared -type f \( -name '*.kt' -o -name '*.java' -o -name '*.gradle' -o -name '*.gradle.kts' \) -print -quit | grep -q .; then
  fail "Android/JVM production source must not be implemented in the Garmin repository."
fi

if grep -RInE --include='*.mc'   '(ABS_(ACCESS|REFRESH)_TOKEN|accessToken|refreshToken|audiobookshelfPassword|serverPassword)'   apps shared; then
  fail "Potential credential-bearing field found in Garmin source."
fi

if grep -RInE --include='*.mc'   '(TYPE_PLAY|TYPE_PAUSE|TYPE_SKIP|sleep_timer_command|force_sync)'   apps shared; then
  fail "Phase 3/4 command or force-sync surface leaked into Phase 2 transport."
fi

echo "Phase 2 repository guardrails PASS"
