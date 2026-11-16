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
