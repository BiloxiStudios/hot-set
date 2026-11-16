# upload-moderation-gate: no second upload before the first failure is fixed

**Why it exists.** Before our jam, an agent hit a validation failure on an asset and resubmitted the same asset 84 times. Resubmitting does not change the asset, so it failed 84 times, and repeated failures can draw an enforcement notice. Ours was eventually overturned, but the lesson stuck: fix the cause first, then upload once.

## The rule
An agent may upload or submit an asset **once per fix**. After any validation or moderation failure it must stop, report, and wait for a changed asset or a changed setting before trying again.

## Steps for the agent
1. **Pre-flight before the first upload.** Check the asset's private flags and settings in the editor (for example texture and mesh flags, naming, sizes, anything the validator reports). Fix what you can see.
2. **Upload once.** Record the asset name, the time and the exact result text.
3. **On failure: stop.** Do not retry. Write down the failure message, what you believe the cause is, and what you will change.
4. **Prove the change.** Retry only after something about the asset or its flags is different. Say what changed in the report.
5. **Two strikes means ask a human.** If the same asset fails twice, stop and hand it to the owner with both messages.

## Add a counter
Keep a tiny log (asset, attempt number, result). The agent reads it before every upload. If the attempt number for an asset is already 2, the answer is "ask".

## Gotchas
- A fast agent is a fast repeater. Speed makes this failure worse, not better.
- "It might be a hiccup" is how you get to 84. Treat the first failure as real.
- The gate is a rule in the agent's instructions plus a log, not a guess about its judgment.

## Copy-paste: the attempt log and gate (`upload_gate.py`)
A small script that keeps a JSON log per asset and blocks a second upload until the first failure is fixed (and always after two failures). The agent runs `check` before every upload and `record` after.

```
python3 upload_gate.py check  <asset>            # exit 0 = go, exit 1 = BLOCKED
python3 upload_gate.py record <asset> ok|fail "<result text>"
python3 upload_gate.py fixed  <asset> "<what you changed>"
```

```python
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
```

## Copy-paste: AGENTS.md lines
```
- Before any asset upload or validation submit: run `python3 upload_gate.py check <asset>`. If it exits non-zero, STOP and report.
- After the attempt: `upload_gate.py record <asset> ok|fail "<exact result text>"`.
- After a failure, change the asset or its flags, then `upload_gate.py fixed <asset> "<what changed>"` before trying again.
- Two failures on one asset: stop and ask a human.
```

## Excerpt: which actions upload, and what stacks
Four editor actions send your project to Epic, so each one is an upload for this gate:

| Editor action | What it does |
|---|---|
| Launch Session | starts a session from the current project |
| Push Changes | sends the open edit into a running session |
| Upload Private Version | the private-code upload (also runs inside Launch Memory Calculation) |
| Launch Memory Calculation | cooks and uploads a private version, then measures |

Facts that make the gate worth having:
- Epic's public content-policy pages say violating content made in UEFN is enforced **even if it is never published**. Read them: https://www.fortnite.com/news/reminder-of-fortnites-content-policies-and-enforcement and the Fortnite Developer Rules.
- **Stacking:** each later upload that still contains a rejected asset can add another sanction. Epic's sanctions page says severity depends on the number of previous sanctions. Do not keep uploading "to see if it cleared."
- **Renaming a file does not change the bytes Epic already rejected.** Fix the pixels (or remove the asset), then upload once. Record the asset's hash before and after your fix; if the hash is unchanged, you have not fixed anything.
- A rejection can arrive hours after the upload, so a clean upload today does not prove tomorrow's.

Watch the editor log. These two line types matter:
```
grep -h "LogVKEditorModeration" UnrealEditorFortnite*.log     # moderation results naming an asset
grep -h "Module upload completed" UnrealEditorFortnite*.log   # every upload, including menu-only private versions
```
Treat any new `LogVKEditorModeration` line as a block until someone has read it and fixed the named asset. Do not turn the gate off to get past a block.

*Excerpt from the uefnmcp skill library (full skills and tooling: uefnmcp.com).*
