#!/usr/bin/env python3
"""Golden Sidecar response shapes, derived from the reviewed MIT upstream route handlers."""
import json
import sys
from pathlib import Path
root = Path(__file__).resolve().parents[2]
def monkey(value):
    if value is None: return "null"
    if isinstance(value, bool): return "true" if value else "false"
    if isinstance(value, str): return json.dumps(value)
    if isinstance(value, (int, float)): return str(value)
    if isinstance(value, list): return "[" + ",".join(map(monkey, value)) + "]"
    return "{" + ",".join(monkey(k) + "=>" + monkey(v) for k,v in value.items()) + "}"
rows=json.loads((root/"shared/test-fixtures/sidecar-v1.json").read_text())["cases"]
expected="// Generated from shared/test-fixtures/sidecar-v1.json.\n(:debug)\nmodule SidecarFixtures { function cases() { return "+monkey(rows)+"; } }\n"
path=root/"apps/audio-provider/source/SidecarFixtures.mc"
if "--write" in sys.argv: path.write_text(expected,newline="\n")
else: assert path.read_text()==expected,"Sidecar fixture generation drifted"
print("Provider/Sidecar contract fixtures PASS")
