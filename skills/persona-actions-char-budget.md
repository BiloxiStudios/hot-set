# persona-actions-char-budget: register persona actions, and keep their text under the limit

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

## Copy-paste: the budget check (`snippets/check_action_budget.py`)
Sums every `@ai_description` string plus each binding's Name and Description. Exit 0 = ok, 1 = within 100 of the limit (warns at 1900), 2 = over 2000. Python standard library only.
```
python check_action_budget.py my_types.verse my_npc.verse --struct my_reply_action
```
Pass only the structs this persona registers. We ran it on a real shipped persona: it printed 1901, matching the hand count; the NPCs spoke at 1901 and went silent at 2003.

## Copy-paste: register a structured action (`snippets/my_persona_actions.verse`)
An NPC behavior that registers one structured action on the persona's AI session. It retries for up to 5 seconds while the persona component arrives, logs an error if it never does, and cancels in `OnEnd`. Put the behavior on the NPC character definition that carries the persona modifier, or set it as the NPC spawner's behavior.
```verse
# Persona structured actions: the NPC fills my_reply_action on every line it speaks.
# Put this class on the Custom NPC Character Definition that carries the Persona Modifier
# (Verse Behavior), or set it as the NPC Spawner's behavior.
# BUDGET: every @ai_description below, plus each binding's Name and Description, counts toward
# a 2000-character limit for ALL actions registered on the persona. Over 2000 the NPC goes
# silent with no compile error. Run check_action_budget.py before you push (warns at 1900).
using { /Fortnite.com/AI }
using { /UnrealEngine.com/Conversations }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Verse.org/Chat }
using { /Verse.org/SceneGraph }
using { /Verse.org/Simulation }

my_npc_log := class(log_channel){}
MyText<localizes>(S:string):message = "{S}"

# Enum values are free: they do not count toward the budget. Prefer an enum to a long description.
my_mood := enum{Calm, Happy, Angry, Afraid}

my_reply_action := struct:
    @ai_description("The emotion of the line you are speaking now.")
    Mood:my_mood = my_mood.Calm

    @ai_description("True to wave while you speak.")
    Wave:logic = false

my_npc_behavior := class(npc_behavior):
    Logger:log = log{Channel := my_npc_log}
    var ReplyCancel:?cancelable = false

    OnBegin<override>()<suspends>:void =
        # The persona component can arrive a frame or two after the spawn: retry for up to 5 s.
        for (Attempt := 1..20):
            if (not ReplyCancel?):
                RegisterReply()
                if (not ReplyCancel?):
                    Sleep(0.25)
        if (not ReplyCancel?):
            Logger.Print("persona actions NOT registered (no persona_component)", ?Level := log_level.Error)

    OnEnd<override>():void =
        if (C := ReplyCancel?):
            C.Cancel()

    RegisterReply():void =
        if (Persona := GetEntity[].GetComponent[persona_component]):
            Session := Persona.GetAISession()
            Binding := prompt_binding_definition:
                Name := MyText("Reply")
                Description := MyText("How you perform the line you are speaking now.")
            # true = required: every reply must fill it.
            set ReplyCancel = option{Session.RegisterAction(Binding, true, my_reply_action, OnReply)}
            Logger.Print("persona actions registered")

    OnReply(Reply:my_reply_action):void =
        Logger.Print("reply mood {MoodName(Reply.Mood)} wave {if (Reply.Wave?) then "yes" else "no"}")

    MoodName(M:my_mood):string =
        case (M):
            my_mood.Happy => "Happy"
            my_mood.Angry => "Angry"
            my_mood.Afraid => "Afraid"
            _ => "Calm"
```
Compile-checked with the hosted Verse check for UEFN 43.10: passed, 0 errors. Names are generic (`my_*`). **Honest limit:** the compile check does not cover assets or device bindings, and we have not run this snippet in a game.

## Excerpt: how RegisterAction and structured output work
- The model fills a struct you defined. `RegisterAction` names it, says when to fill it, and names the function that receives it. Responses and structured output must be English.
- Signature: `RegisterAction(Definition:prompt_binding_definition, Required:logic, output_type:type, Callback)`. `Definition` has a `Name` and a `Description`; the description is what the model matches. `Required := true` means the struct is filled every time the persona speaks; `false` means only when the description matches. Pass the struct **type**, not an instance.
- Each registration returns its own `cancelable`. Store it (`?cancelable`) and `Cancel()` it in `OnEnd`.
- Write `logic`, not `bool`. Test it with `if (Response.Flag?):`. Use an enum instead of a long description when you can; enum values cost nothing against the budget.
- Do not run gameplay inside the callback. Set a flag, and apply it when the line finishes (`StopSayEvent`, only when it was not interrupted).
- `message` text is redacted in logs, so `Print` will not show it. Show it on a widget or device.

*Excerpt from the uefnmcp skill library (full skills and tooling: uefnmcp.com).*
