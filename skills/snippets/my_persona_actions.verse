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
