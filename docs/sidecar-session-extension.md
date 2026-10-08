# Optional BookWave session extension for WatchShelf Sidecar

**Status:** Validated source/build candidate; not deployed. Signed-in Android exchange is pending explicit
credential-egress authorization. Existing WatchShelf and legacy provider login routes are unchanged.

BookWave discards sign-in passwords. Its stored access token can be exchanged by the **phone** for
an opaque Sidecar UUID; the normal ABS credential never crosses BLE or enters watch Storage.
Sidecar must offer this extension first. Sending an ABS token directly to the existing `/login` route
or treating one as an opaque watch session is unsupported.

| Route | Contract |
| --- | --- |
| GET `/bookwave/capabilities` | Credential-free `{"v":1,"features":["session"]}`; normal JSON/no-store. |
| POST `/bookwave/session` | Explicit Bearer access token; JSON `{username}` only, max1KB. Validate through Sidecar's configured ABS `POST /api/authorize`, with no redirect and8s timeout. |
| Success | `{"v":1,"user":{"token":"opaque-UUID","username":"verified-user"},"renewal":"sidecar-or-phone"}`. Unknown fields tolerated. |
| Failure | JSON fixed errors;401 invalid session,403 principal/download mismatch,400 malformed,413 too large,502 upstream failure. No credential/body values in errors/logs. |

Principal and Download grant come from ABS, not client-supplied username/JWT claims. Sidecar finds
only that authenticated account's session. A retained independently acquired refresh session is
reused. Otherwise it creates/updates an access-only session and reports `renewal:phone`. Such a
session needs a fresh phone exchange before access expiry; it is not independently renewable.
**Never copy Android's rotating refresh token into Sidecar**: two refresh owners would invalidate
each other's credentials. Already downloaded watch audio remains offline-playable after access expiry.

The additive provider request is `setup_session` plus `url`, verified `user`, opaque `session` and
the existing envelope. It is transient, not queued/Room-persisted; only provider's account-bound
Sidecar UUID survives. Matching launch/profile/nonce, account anchor, health and libraries must
validate before committing. Companion is credential-free.

## Prepare a reproducible candidate

Use WatchShelf MIT pin `93ac7507dae1cae1221509cefd97441dab36e955` (Christian Brooker).
The builder checks the exact server source SHA256 before adding the two routes; modified/upgraded
sources fail closed and require review. It writes only ignored `out/sidecar`.

```sh
node --test sidecar/*.test.mjs
node tools/sidecar/build.mjs /path/to/pinned/WatchShelf
node --check out/sidecar/server.js
docker build -t bookwave-watchshelf-session-test out/sidecar
```

Preserve the deployed ABS_URL, BASE_PATH, SESSIONS_FILE volume and other settings; retain the MIT
license. Do not log or copy session-file contents into documentation. Back up/restore the existing
image and configuration for rollback. Run capability, health, existing login/catalogue, duration,
transcode, renewal and cross-account acceptance in a separate test deployment before production.
Production promotion/restart is a separate explicit action; this repository build does not deploy it.
