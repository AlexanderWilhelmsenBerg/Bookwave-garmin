# BookWave Phone ↔ Watch Protocol

**Current Phase 2 implementation (2026-10-07):** foreground phone transport, negotiated ordered
snapshot delivery, durable clear/snapshot acknowledgements and bounded reconnect handling are
implemented. See [the shared wire contract](transport-contract.md). Build/test-compilation and physical acceptance
are recorded separately in the Phase 2 inventory. Commands, reconciliation/Force sync,
provider/device controls and BookWave complication publishing are selected planned work
([provider plan](device-management-plan.md), [future face feed](watchface-state-plan.md)).
Watch face and Data Field implementation remain deferred. Earlier Phase 1 descriptions below
describe the persisted model and its original acceptance, not the current transport scope.


## Persisted model status

Phase 1 defines the conceptual playback contract and the Garmin persisted representation.

Phase 1 did not finalize wire encoding. Phase 2 now uses [the shared transport contract](transport-contract.md).

The Phase 2 document owns envelope/ack/replay/negotiation rules; the model rules below remain current.

## Conceptual PlaybackSnapshot

```text
PlaybackSnapshot
  protocolVersion
  profileId
  bookId
  title
  author
  chapterTitle
  positionMs
  durationMs
  updatedAt
  playing
  source
```

Allowed `source` values:

- `PHONE`
- `GARMIN`
- `SERVER`

## Current protocol version

Phase 1 uses protocol major version:

`1`

The persisted representation stores this integer as `protocolVersion`.

Within protocol major 1:

- unknown fields are ignored;
- missing required fields are rejected;
- an unsupported major is rejected;
- no state is inferred from field order;
- a rejected candidate never overwrites the last known good snapshot.

If a future wire format needs explicit major/minor components, it may introduce them during Phase 2 while preserving the meaning of major version 1.

## Field contract

| Field | Required | Current persisted type | Rules |
| --- | --- | --- | --- |
| `protocolVersion` | yes | Number | Must equal supported major (1). |
| `profileId` | yes | String | Non-empty, max 96 chars. |
| `bookId` | yes | String | Non-empty, max 96 chars. |
| `title` | yes | String | Non-empty, max 160 chars. |
| `author` | no | String/null | Max 120 chars when present. |
| `chapterTitle` | no | String/null | Max 160 chars when present. |
| `positionMs` | yes | Number/Long | Must be >= 0. |
| `durationMs` | no | Number/Long/null | Null means unknown. If present, must be > 0. |
| `updatedAt` | yes | Number/Long | Unix epoch milliseconds, > 0. |
| `playing` | yes | Boolean | Playback intent/state only; does not authorize playback. |
| `source` | yes | String | PHONE, GARMIN, or SERVER. |

## Position and duration semantics

Positions are not monotonic authority.

A deliberate rewind is legitimate state, so future reconciliation must never implement `max(positionMs)`.

When duration is known:

- `positionMs > durationMs` is rejected as corrupted state;
- the validator does not silently clamp it.

When duration is unknown:

- `durationMs = null`;
- percentage renders as unknown;
- elapsed time may still render.

`durationMs = 0` is rejected to avoid conflating unknown duration with an invalid zero-length book.

## Timestamp semantics

`updatedAt` is Unix epoch milliseconds.

The timestamp is retained because later reconciliation requires event recency. Phase 1 does not use it to choose between competing sources; it only displays stored-state age.

## Persisted representation

The current Garmin representation is a `Lang.Dictionary` containing only the fields above. It is stored using `Toybox.Application.Storage`.

This is a persistence representation, not a declaration that the Phase 2 wire protocol will also be a raw Monkey C dictionary.

## Validation behavior

Validation rejects:

- wrong root type;
- unsupported protocol major;
- missing/empty required identity fields;
- oversized bounded text;
- negative positions;
- zero/negative known durations;
- position beyond known duration;
- invalid timestamps;
- non-boolean playing state;
- unknown source values.

Optional author/chapter metadata may be absent.

Unknown future fields are ignored for compatible protocol-major messages.

## Privacy

The snapshot may contain playback/display metadata only.

It must never contain:

- Audiobookshelf password;
- normal ABS access token;
- refresh token;
- BookWave server credential.

The persistence layer exposes a clear operation so future profile-lock/privacy messages can remove previously stored private metadata before a replacement safe state is accepted.

## Phase 2 wire contract

The [shared transport contract](transport-contract.md) finalizes v/t/id/r/ts/p plus watch nonce s and
sequence n, negotiated ordered_state, clear-before-metadata and correlated durable acks. A Phase 1
snapshot is the snapshot message payload, not its envelope. Read that document for lifecycle/retry and
foreground limits. Physical interoperability is still tracked under [G-02 acceptance](testing/phase-2-transport.md).
