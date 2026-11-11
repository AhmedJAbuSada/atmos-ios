#!/usr/bin/env bash
# Prints an xcodebuild destination for the newest available iPhone simulator. Simulator
# names change with every Xcode release, so CI should not hard-code "iPhone 16".
set -euo pipefail
xcrun simctl list devices available --json | python3 -c '
import json, sys
devices = json.load(sys.stdin)["devices"]
ios = sorted((runtime, d) for runtime, list_ in devices.items() if "iOS" in runtime
             for d in list_ if d["name"].startswith("iPhone"))
runtime, device = ios[-1]
print(f"platform=iOS Simulator,id={device[\"udid\"]}")
'
