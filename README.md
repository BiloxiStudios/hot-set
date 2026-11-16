# HOT SET

![HOT SET](assets/hotset-title-wide.jpg)

**You're the director. They're the problem.**

HOT SET is a UEFN game where you direct AI actors by voice. Pick a genre and a set, cast your stars, call Action, and watch them improvise. Cut in with notes, send a quick "Bigger!", throw in a prop, and look out for the occasional Guest Star crashing through the door. We built it in four days for the 2026 Epic AI MegaJam, with a crew of humans and a rather large crew of AI agents.

- 🎬 **Trailer:** https://youtu.be/xNuTzG2VBj4
- 📓 **Build log (devlog):** https://www.biloxistudios.com/blog/megajam26-devlog
- 🔧 **Postmortem** (what worked, what broke, what we cut): https://www.biloxistudios.com/blog/megajam26-postmortem

## What's in this repo
| path | what |
|---|---|
| [`skills/`](skills/) | six short, generic starter skills for people building with AI agents in UEFN (see below) |
| `assets/` | the HOT SET logo |

The game itself is a UEFN project. **Island code coming soon (public release).** The public code will come after we polish it over the next few weeks.

## The starter skills
Small markdown files you can drop into your own agent setup (an AGENTS.md, a skills folder or a system prompt). They are short synopses of rules that cost us time.

| skill | one line |
|---|---|
| [upload-moderation-gate](skills/upload-moderation-gate.md) | never let an agent upload an asset again before the validation failure is fixed |
| [persona-actions-char-budget](skills/persona-actions-char-budget.md) | count your NPC's registered-action text before you push; past 2000 characters the NPC goes silent |
| [agent-leash-basics](skills/agent-leash-basics.md) | lanes, labels and gates that keep fast agents from repeating a mistake fast |
| [frame-safe-public-crops](skills/frame-safe-public-crops.md) | crop and check screenshots and clips before they go public |
| [honest-devlog](skills/honest-devlog.md) | PLAYED / BUILT / NOT seen: a devlog that never claims more than someone saw |
| [ui-widget-blueprints-first](skills/ui-widget-blueprints-first.md) | every player-facing screen is a Widget Blueprint; Verse holds data and events only |

## PLAYTESTERS WANTED
We're polishing HOT SET over the next few weeks: mobile touch (some menus don't tap yet, sorry), more characters and more sets. Want in on the private playtest? Join the Discord and reach out: https://discord.gg/fWHBt5kyjj

Feedback, good or bad (please, no AI hate): on social media, on Discord, or at feedback@biloxistudios.com.

## Credits
Made by **BizaNator** (Verse programmer, AI tooling, storytelling) and **RinEllaSky** (technical artist, UI, visual cohesion), with a crew of AI agents.

HOT SET was made for the 2026 Epic AI MegaJam. Made in UEFN.

## License
- The README and documentation text are licensed under [CC BY 4.0](LICENSE).
- The files in [`skills/`](skills/) are licensed under the [MIT License](skills/LICENSE) (Copyright (c) 2026 Biloxi Studios Inc.).
- The HOT SET name, logo and art (title image, trailer, screenshots) are (c) Biloxi Studios Inc., all rights reserved, and not covered by the licenses above.
