#!/usr/bin/env python3
"""Attempt log + gate for asset uploads. Usage:
  upload_gate.py check  <asset>             exit 0 = may upload, exit 1 = BLOCKED (read the message)
  upload_gate.py record <asset> ok|fail [message]
  upload_gate.py fixed  <asset> <what changed>   (a human or the agent, after really changing the asset)
"""
import json, sys, time, pathlib
LOG = pathlib.Path("upload_attempts.json")
log = json.loads(LOG.read_text()) if LOG.exists() else {}
cmd, asset, *rest = sys.argv[1:] + [""] * (3 - len(sys.argv[1:]))
e = log.setdefault(asset, {"fails": 0, "needs_fix": False, "history": []})
if cmd == "check":
    if e["fails"] >= 2:
        sys.exit(f"BLOCKED: {asset} failed {e['fails']} times. Stop and ask a human.")
    if e["needs_fix"]:
        sys.exit(f"BLOCKED: {asset} failed last time. Change the asset, then run: fixed {asset} <what changed>")
    sys.exit(0)
if cmd == "record":
    ok = rest[0] == "ok"
    e["fails"] += 0 if ok else 1
    e["needs_fix"] = not ok
    e["history"].append({"t": time.strftime("%F %T"), "result": rest[0], "msg": " ".join(rest[1:])})
elif cmd == "fixed":
    e["needs_fix"] = False
    e["history"].append({"t": time.strftime("%F %T"), "result": "fixed", "msg": " ".join(rest)})
LOG.write_text(json.dumps(log, indent=2))
