# ui-widget-blueprints-first: Widget Blueprints for screens, Verse for data

**Why it exists.** A Verse-built menu looked fine with a mouse and could not be driven with a controller. Our art team also could not restyle or animate it. We moved every player-facing screen to Widget Blueprints (WBPs) and wrote down what bit us.

## The rule
- Every player-facing screen is a UMG Widget Blueprint. Verse holds **data and events only**: it sets fields on the widget and reacts to its events. It does not build a canvas, stack box, button or text block for a player-facing screen. (Debug menus nobody sees are the one exception.)
- Layout reacts to screen size: anchors and size boxes, not fixed pixels that only fit one resolution.
- Animation, material changes and sounds live on the widget's own animation tracks and button styles.

## Inputs
- Show each button's bound **input action** with its glyph (an action widget), so the right key picture appears per device. Never hard-code key names. Set the input action on the action widget **in the designer**; Verse cannot assign an input action asset to a widget field, so drive the glyph from Verse with a logic field bound to its Visibility (or remove it). Glyphs draw only in input mode All with the UI input mapping added.
- **A controller is the witness, not a mouse.** A screen is not done until someone has driven it end to end with a controller, and again with mouse and keyboard. Say which inputs you tested.

## Hard-won gotchas
1. **Some stock input actions are illegal at push.** Several actions draw nothing or fail validation with a vague message. Check an action on a real device before you push, and keep a short list of the ones that work.
2. **A Collapsed glyph can re-show at runtime.** Hiding it in the designer is not enough; the widget re-shows from its input action. Remove the glyph widget instead.
3. **Verse fields appear only after you press Compile inside the UMG editor, then save.** Opening and saving once was not enough for us; a tool-driven compile and save left the generated class empty. If Verse cannot see a field, compile in the widget editor itself.
4. **Set focus from Verse every time a widget is shown or changes state.** A gamepad can only press what has focus. Make the root widget focusable too, or the focus call quietly does nothing.
5. **No dead ends.** Every button's up, down, left and right navigation lands somewhere.
6. **No hidden second step.** A button never waits for a second press or hold unless the prompt for it is on screen.

## One state language
Pick one look for **hover, picked, locked and disabled** and use it on every screen, so players learn it once. Make touch targets large enough for a thumb.

## Checklist before you call a screen done
- [ ] Only data and events in Verse
- [ ] Glyph on every input, device-reactive
- [ ] Focus set on show; root focusable; no dead-end navigation
- [ ] Hover, picked, locked and disabled states match the rest of the game
- [ ] Driven with a controller and with mouse and keyboard, and the hand-off says so

## Copy-paste: show a menu, focus it, wait for a button (`snippets/my_widget_menu.verse`)
`ShowMenuUntil` adds the UI input mapping (removing first, so it is never added twice), adds the widget in input mode All, sets focus twice (the first call can land before the widget is built), awaits the widget's event until a closing button, then removes it.
```verse
# Show a Widget Blueprint to one player, give it pad focus, wait for one of its buttons, take it down.
# Generic: works for ANY class UEFN generates from a Widget Blueprint, because that class is a `widget`
# and its UIAction(int) event field is an event(tuple(int)), which is an awaitable(tuple(int)).
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Concurrency }
using { /Verse.org/Input }
using { /Verse.org/Input/UI }
using { /Verse.org/Simulation }

# Returns the int of the button that closed the menu (one of CloseOn), or -1 if the player has no UI.
ShowMenuUntil(Player:player, Menu:widget, Presses:awaitable(tuple(int)), CloseOn:[]int)<suspends>:int =
    var Result:int = -1
    if (PlayerUI := GetPlayerUI[Player]):
        # IA_UI_* glyphs render and the UI actions fire only while a mapping that holds them is added
        # AND the widget is in input mode All. With mode None the glyph is blank and presses are silent.
        # Remove before Add, so a second call cannot add the mapping twice (each key would fire twice).
        if (PlayerInput := GetPlayerInput[Player]):
            PlayerInput.RemoveInputMapping(InventoryMenuMapping)
            PlayerInput.AddInputMapping(InventoryMenuMapping)
        PlayerUI.AddWidget(Menu, player_ui_slot{InputMode := ui_input_mode.All, ZOrder := 5})
        # SetFocus gives the pad the WBP's first focus target (its Desired Focus / first button).
        # The first call can land before the widget is built: repeat it once.
        PlayerUI.SetFocus(Menu)
        Sleep(0.1)
        PlayerUI.SetFocus(Menu)
        # A WBP event field is an event, not a subscribable: Await it in a loop (there is no Subscribe).
        loop:
            Payload := Presses.Await()
            Pressed := Payload(0)
            if (CloseOn.Find[Pressed]):
                set Result = Pressed
                break
        PlayerUI.RemoveWidget(Menu)
    Result
```
Compile-checked with the hosted Verse check for UEFN 43.10 (module with a caller): passed, 0 errors; the call check found no unknown or misused symbols.

**The caller** (four lines; they compile only in a project that has the widget, because UEFN generates the class from your Widget Blueprint):
```verse
Menu := WBP_MyMenu{}
set Menu.StartText = MenuText("START")    # a message Verse field
set Menu.UseGlyphShown = true             # a logic Verse field bound to the glyph's Visibility
Pressed := ShowMenuUntil(Player, Menu, Menu.UIAction, array{0, 1})
```
In the designer, each button fires the widget's `UIAction` event with its own number, and the first button is the first focus target.

**Honest limits.** The four caller lines cannot be checked without your widget asset (a stand-in `class(widget)` is a compile error); their shape matches a real 43.10 export. Nothing here was run in a game. Mode All also blocks the persona talk key, so take the menu down before players need to talk.

## Excerpt: Verse fields and events on a Widget Blueprint
- **Instantiate** the class UEFN generated from your WBP as a plain field on the device (not `var`, not `@editable`): `Widget : UI.Widgets.UW_MyHud = UI.Widgets.UW_MyHud{}`. Every folder that holds widgets needs a `<public>` module declared in a `.verse` file.
- **Set Verse fields** from code: `set Widget.ScoreField = ScoreLabel(Score)`. Supported field types (read from a live 43.10 editor): `logic`, `int`, `float`, `string`, `message`, `color`, `color_alpha`, `texture`, `material`, and `event` (event parameters `logic`, `int` or `float`). Text must be a `message` built with a `<localizes>` function.
- **Events:** an event field is a Verse `event`, so `Widget.ClickedEvent.Await()` works with no helper; an `event(tuple(int))` field gives `Payload(0)`. If you subscribe with a helper, store it and `Cancel()` it on teardown, or it fires into a dead page.
- `GetPlayerUI` is failable: call it as `GetPlayerUI[Player]` inside `if`. Widgets are per player; never share one instance across players, and remove the same instance you added.
- `SetFocus` on a widget does nothing unless its root has **Is Focusable** on and a Desired Focus Widget that is enabled.
- Verse fields are renamed badly in the editor (renaming reports the name is in use), so choose final names when you create them.

*Excerpt from the uefnmcp skill library (full skills and tooling: uefnmcp.com).*
