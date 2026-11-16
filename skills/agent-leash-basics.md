# agent-leash-basics: lanes, labels and gates for a crew of fast agents

**Why it exists.** Agents are quick, confident and happy to repeat a mistake at machine speed. Four days of crew-of-agents work taught us a few cheap habits.

## 1. One owner per area
Give every agent a lane (a folder, a feature). It edits only its lane. If it needs a change elsewhere, it asks the lane's owner.

## 2. A second reader for every change
Nothing reaches a human tester until a second agent has read it. Compile first: nobody reads code that does not build.

## 3. Three honest labels
Every status line says one of:
- **PLAYED**: a person ran it in a game session.
- **BUILT**: it compiles and a second reader looked, but nobody saw it work.
- **NOT seen**: neither.
"Done" without a label does not count.

## 4. A witness that only records
Keep one agent that never fixes anything. It records what was seen, by whom, in which build. Done always comes with a receipt.

## 5. Stop rules in the instructions
Put these in every agent's instructions file:
- Never retry a failed upload or validation before the cause is fixed.
- Never press Continue on an engine modal that warns it may strip placed objects; stop and report.
- Never print, paste or commit a secret.
- Prove the cause before the fix: list guesses, test one at a time, change one thing.

## 6. Small numbered changes
One change per task, one clear description, pulled and rebased before you submit. Small changes are easy to read and easy to blame.

## Gotchas
- Shelving and review loops add real delay. Loosen them late in a deadline once trust is earned, but keep the labels.
- Instructions files drift. Re-read them when an agent repeats a mistake; the fix is usually a new rule.

## Copy-paste: AGENTS.md lines
```
- Work only in your lane (folder/feature). Ask the lane's owner for anything else.
- Compile before asking anyone to read your change. Keep each change small, with a clear description.
- Label every status: PLAYED (a person ran it) / BUILT (compiles, a second reader looked) / NOT seen.
- Never retry a failed upload or validation before the cause is fixed. Two failures: ask a human.
- Prove the cause before the fix: list guesses, test one at a time, change one thing.
- If an engine modal warns it may strip or delete placed objects, stop and report. Never press Continue.
- Never print, paste or commit a secret.
```
