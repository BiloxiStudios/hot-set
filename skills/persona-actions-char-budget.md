# persona-actions-char-budget: keep an NPC's action text under the limit

**Why it exists.** In UEFN, an AI NPC (persona) can register actions the language model may call. The text that describes those actions has a hard size limit of 2000 characters per NPC. Go over it and the NPC simply goes silent: no build error, nothing in play, just quiet actors. We lost an afternoon to this at the worst time.

## What to count (as measured in our project)
- The description text on every field of every struct you register as an action.
- Each prompt binding's name and description.
- Field names and enum value names did **not** push us over in our measurements, but check yours: our own count went wrong once by adding them.

## Our numbers
| version | total | result |
|---|---|---|
| shipped wording | 1901 | NPCs spoke |
| wording made about 100 characters longer | 2003 | every NPC silent, editor warned the registered actions field was over 2000 |
| trimmed wording | 1856 | counted fine |

## Steps
1. Write a tiny script that sums the description text in your action structs and bindings. Run it before every change to that text.
2. Post the before and after totals in your change description.
3. Keep 100 or more characters of margin (aim under 1900).
4. Ship a text change alone, never bundled with other work, so a silence has one suspect.
5. If every NPC goes silent right after a push, check this total first, before voice channels or devices.

## Gotchas
- The failure is silent in play. Look for the editor warning.
- Prefer choosing things in code (lookups, enums) over longer instructions. Prompt text that is not part of a registered action does not count toward this limit.
- Your layout differs: adjust the script's patterns to your struct and binding names.
