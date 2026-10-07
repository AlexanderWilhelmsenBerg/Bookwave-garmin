#!/usr/bin/env python3
"""Check that simulator fixtures are generated from the common Android/watch golden contract."""
import json
from pathlib import Path

root = Path(__file__).resolve().parents[2]
def monkey(value):
    if value is None: return "null"
    if isinstance(value, bool): return "true" if value else "false"
    if isinstance(value, str): return json.dumps(value)
    if isinstance(value, int): return str(value) + ("l" if abs(value) > 2147483647 else "")
    if isinstance(value, float): return str(value)
    if isinstance(value, list): return "[" + ", ".join(map(monkey, value)) + "]"
    return "{" + ", ".join(monkey(k) + " => " + monkey(v) for k,v in value.items()) + "}"
cases = json.loads((root / "shared/test-fixtures/transport-v1.json").read_text())
expected = "// Generated from transport-v1.json; checked by tools/ci/check_transport_fixtures.py.\n(:debug)\nmodule TransportFixtures {\n    function cases() {\n        return " + monkey(cases) + ";\n    }\n}\n"
assert (root / "shared/test-fixtures/TransportFixtures.mc").read_text() == expected, "Golden fixtures drifted"
print("Common transport fixture generation PASS")
