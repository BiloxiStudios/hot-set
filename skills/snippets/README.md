# Snippets for persona-actions-char-budget and ui-widget-blueprints-first

Paste-ready code for the two starter skills. Names are generic (`my_*`). Both Verse files passed the
hosted Verse compile check for UEFN 43.10 with 0 errors. That check is a front-end compile without the
editor: it does not cover assets, device bindings, or an island build.

| file | what it is | checked |
|---|---|---|
| `my_persona_actions.verse` | NPC behavior that registers one structured action (`@ai_description` fields + a prompt binding) on the persona's AI session, retries while the persona component arrives, cancels on end | compile_check (snippet): passed, 0 errors |
| `check_action_budget.py` | sums the `@ai_description` text plus each binding's Name and Description; warns at 1900, fails above 2000 | run on real files, below |
| `my_widget_menu.verse` | `ShowMenuUntil`: adds a Widget Blueprint in input mode All, adds the UI input mapping (so IA glyphs draw), sets focus twice, awaits its `UIAction` event until a closing button, removes it | compile_check (module, with a caller): passed, 0 errors |

## Persona: what counts toward 2000 characters
Every `@ai_description` string on the fields of each struct you register with `RegisterAction`, plus each
`prompt_binding_definition`'s Name and Description. Field names and enum value names do not count. Over 2000
the NPC goes silent in play with no compile error.

```
python check_action_budget.py my_types.verse my_npc.verse --struct my_reply_action
```
Exit 0 = ok, 1 = within 100 of the limit, 2 = over. Pass only the structs this persona registers.
Tested: the sample file totals 125. On a real shipped actor persona (two structs, 25 strings) it printed 1901,
which matches that NPC's hand-measured total; the actors spoke in play at 1901 and went silent at 2003.

## Widget Blueprint: the caller
UEFN generates a Verse class from your WBP: `class(widget)` with one `var` per Verse field and
`UIAction<public>:event(tuple(int))` for an event field `UIAction(int)`. You cannot write that class yourself
(subclassing `widget` is error 3593), so the helper takes any `widget` plus the event. In your device:

```verse
# WBP_MyMenu = the class UEFN generated from your Widget Blueprint
Menu := WBP_MyMenu{}
set Menu.StartText = MenuText("START")    # a message Verse field
set Menu.UseGlyphShown = true             # a logic Verse field bound to the glyph's Visibility
Pressed := ShowMenuUntil(Player, Menu, Menu.UIAction, array{0, 1})
```
These four lines compile only in a project that has the WBP; the field shapes match a real 43.10 export.

WBP side (designer):
- The glyph is an ActionWidget. Set its enhanced input action to the `IA_UI_*` asset for the key and its display type to Icon. Verse cannot assign an input action asset to a WBP field, so drive the glyph from Verse with a logic field bound to its Visibility (or remove it).
- Each button fires `UIAction` with its own int. Make the first button the WBP's first focus target.
- Verse fields appear in Verse only after you press Compile inside the UMG editor and save.
- With input mode None the `IA_UI_*` glyphs draw blank and the UI actions do not fire. Mode All also blocks the persona talk key, so take the menu down before players need to talk.
