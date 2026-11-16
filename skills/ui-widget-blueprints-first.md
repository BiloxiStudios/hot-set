# ui-widget-blueprints-first: Widget Blueprints for screens, Verse for data

**Why it exists.** A Verse-built menu looked fine with a mouse and could not be driven with a controller. Our art team also could not restyle or animate it. We moved every player-facing screen to Widget Blueprints (WBPs) and wrote down what bit us.

## The rule
- Every player-facing screen is a UMG Widget Blueprint. Verse holds **data and events only**: it sets fields on the widget and reacts to its events. It does not build a canvas, stack box, button or text block for a player-facing screen. (Debug menus nobody sees are the one exception.)
- Layout reacts to screen size: anchors and size boxes, not fixed pixels that only fit one resolution.
- Animation, material changes and sounds live on the widget's own animation tracks and button styles.

## Inputs
- Show each button's bound **input action** with its glyph (an action widget), so the right key picture appears per device. Never hard-code key names.
- **A controller is the witness, not a mouse.** A screen is not done until someone has driven it end to end with a controller, and again with mouse and keyboard. Say which inputs you tested.

## Hard-won gotchas
1. **Some stock input actions are illegal at push.** Several actions draw nothing or fail validation with a vague message. Check an action on a real device before you push, and keep a short list of the ones that work.
2. **A Collapsed glyph can re-show at runtime.** Hiding it in the designer is not enough; the widget re-shows from its input action. Remove the glyph widget instead.
3. **Widget fields export only after the WBP is opened and saved once.** If Verse cannot see a field, open and save the widget, then rebuild.
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
