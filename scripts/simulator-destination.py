#!/usr/bin/env python3
"""Prints an xcodebuild destination for the newest available iPhone simulator.

Simulator names change with every Xcode release, so CI should not hard-code "iPhone 16".
Reads `xcrun simctl list devices available --json` from standard input.
"""
import json
import re
import sys


def runtime_version(runtime: str) -> tuple:
    # "com.apple.CoreSimulator.SimRuntime.iOS-18-2" -> (18, 2)
    return tuple(int(part) for part in re.findall(r"\d+", runtime.split("iOS")[-1]))


def main() -> None:
    devices = json.load(sys.stdin)["devices"]
    candidates = [
        (runtime_version(runtime), device["name"], device["udid"])
        for runtime, runtime_devices in devices.items()
        if "iOS" in runtime
        for device in runtime_devices
        if device["name"].startswith("iPhone")
    ]
    if not candidates:
        sys.exit("No available iPhone simulator found.")
    version, name, udid = max(candidates)
    print(f"Using {name}, iOS {'.'.join(map(str, version))}", file=sys.stderr)
    print("platform=iOS Simulator,id=" + udid)


if __name__ == "__main__":
    main()
