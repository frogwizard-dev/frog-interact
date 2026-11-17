local _, ns = ...
-- The settings controls are FrogLib's; every change calls ns.Refresh (Core.lua).
local UI = FrogLib.UI.Kit({ refresh = ns.Refresh })

local ARCS = UI.Options(0, "Narrow, straight ahead", 1, "Wide, in front of you", 2, "All round you")

local function Build(page)
    local db = ns.db
    local place = UI.Placer()
    place(UI.Checkbox(page, "Mark what your Interact key will use, and let it work with a mouse and keyboard",
        db, "enabled"), 28)
    place(UI.Help(page, "Your Interact key (Options > Keybindings > Targeting: Interact with Target) uses "
        .. "whatever the game has picked out in front of you: talk to an NPC, open a chest, mine ore, pick "
        .. "a herb, loot a corpse, click a bobber.", 420), 44, 4)

    place(UI.Label(page, "Marked with"), 22)
    place(UI.Checkbox(page, "An icon over NPCs (talk, trade, loot)", db, "npcIcons"), 26, 12)
    place(UI.Checkbox(page, "An icon over objects (chests, ore, herbs, mailboxes, bobbers)", db, "objectIcons"), 26, 12)
    place(UI.Checkbox(page, "... and over the less important ones too", db, "lowPriority"), 26, 32)
    place(UI.Checkbox(page, "Its name above it", db, "names"), 26, 12)
    place(UI.Stepper(page, "Name size", 10, 30, 1, db, "nameSize"), 28, 32)
    place(UI.Checkbox(page, "Its tooltip, as if you were pointing at it", db, "tooltip"), 26, 12)
    place(UI.Checkbox(page, "A soft sound when something comes into reach", db, "sound"), 30, 12)

    place(UI.Label(page, "Reach"), 22)
    place(UI.Stepper(page, "How far (yards)", 5, 40, 1, db, "range"), 28, 12)
    place(UI.Dropdown(page, "Where", ARCS, db, "arc"), 30, 12)
    place(UI.Checkbox(page, "The reach as a hard limit (not each thing's own distance)", db, "hard"), 26, 12)
    place(UI.Help(page, "The game may still stop short for some things. FrogFish widens all of this while a "
        .. "fishing pole is on, and these come back when it comes off. Turned off, the game's own settings "
        .. "are back as they were.", 420), 44, 4)
    place(UI.Help(page, "/fi status says what's picked out now.", 420), 20, 4)
end

function ns.ToggleConfig()
    if not ns.window then
        ns.window = UI.Window("FrogInteractConfig", "FrogInteract", 470, 560, { { "main", "FrogInteract", Build } })
        return
    end
    ns.window:SetShown(not ns.window:IsShown())
end

-- Its entry in the game's Options > AddOns list.
FrogLib.Options.Add("FrogInteract", ns, {
    open = function()
        if not (ns.window and ns.window:IsShown()) then ns.ToggleConfig() end
    end,
    commands = {
        { "/fi", "open or close the settings" },
        { "/fi on", "mark what the Interact key will use (/fi off: the game's own settings back)" },
        { "/fi status", "what's picked out now, and your Interact key" },
    },
})
