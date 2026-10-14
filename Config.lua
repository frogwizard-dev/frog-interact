local _, ns = ...
local UI = ns.UI

local ARCS = UI.Options(0, "Narrow, straight ahead", 1, "Wide, in front of you", 2, "All round you")

local function Build(p)
    local db = ns.db
    local place = UI.Placer()
    place(UI.Checkbox(p, "Mark what your Interact key will use, and let it work with a mouse and keyboard",
        function() return db.enabled end, function(v) db.enabled = v end), 28)
    place(UI.Help(p, "Your Interact key (Options > Keybindings > Targeting: Interact with Target) uses "
        .. "whatever the game has picked out in front of you: talk to an NPC, open a chest, mine ore, pick "
        .. "a herb, loot a corpse, click a bobber.", 420), 44, 4)

    place(UI.Label(p, "Marked with"), 22)
    place(UI.Checkbox(p, "An icon over NPCs (talk, trade, loot)", function() return db.npcIcons end,
        function(v) db.npcIcons = v end), 26, 12)
    place(UI.Checkbox(p, "An icon over objects (chests, ore, herbs, mailboxes, bobbers)",
        function() return db.objectIcons end, function(v) db.objectIcons = v end), 26, 12)
    place(UI.Checkbox(p, "... and over the less important ones too", function() return db.lowPriority end,
        function(v) db.lowPriority = v end), 26, 32)
    place(UI.Checkbox(p, "Its name above it", function() return db.names end, function(v) db.names = v end), 26, 12)
    place(UI.Stepper(p, "Name size", 10, 30, 1, function() return db.nameSize end,
        function(v) db.nameSize = v end), 28, 32)
    place(UI.Checkbox(p, "Its tooltip, as if you were pointing at it", function() return db.tooltip end,
        function(v) db.tooltip = v end), 26, 12)
    place(UI.Checkbox(p, "A soft sound when something comes into reach", function() return db.sound end,
        function(v) db.sound = v end), 30, 12)

    place(UI.Label(p, "Reach"), 22)
    place(UI.Stepper(p, "How far (yards)", 5, 40, 1, function() return db.range end,
        function(v) db.range = v end), 28, 12)
    place(UI.Dropdown(p, "Where", ARCS, function() return db.arc end, function(v) db.arc = v end), 30, 12)
    place(UI.Checkbox(p, "The reach as a hard limit (not each thing's own distance)", function() return db.hard end,
        function(v) db.hard = v end), 26, 12)
    place(UI.Help(p, "The game may still stop short for some things. FrogFish widens all of this while a "
        .. "fishing pole is on, and these come back when it comes off. Turned off, the game's own settings "
        .. "are back as they were.", 420), 44, 4)
    place(UI.Help(p, "/fi status says what's picked out now.", 420), 20, 4)
end

function ns.ToggleConfig()
    if not ns.window then
        ns.window = UI.Window("FrogInteractConfig", "FrogInteract", 470, 560, { { "main", "FrogInteract", Build } })
        return
    end
    ns.window:SetShown(not ns.window:IsShown())
end

-- Its entry in the game's Options > AddOns list (FrogLib's Options).
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
