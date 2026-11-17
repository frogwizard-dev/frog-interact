local ADDON, ns = ...

-- The game's Interact key, made to work with a mouse and keyboard: the game picks out what's in
-- front of you (its "soft target": an NPC, chest, ore, herb, mailbox, bobber) and marks it, from its
-- own settings kept on here. They go through FrogLib's CVar at layer 10, so FrogFish's fishing ones
-- sit on top while a pole's on, and the game's own come back when FrogInteract is off or removed.

ns.defaults = {
    enabled = true,
    npcIcons = true,     -- an icon over an NPC you can talk to, trade with or loot
    objectIcons = true,  -- ... over objects: chests, ore, herbs, mailboxes, a fishing bobber
    lowPriority = false, -- ... and over the less important ones too
    names = true,        -- its name above it
    nameSize = 20,       -- the name's size
    tooltip = false,     -- its tooltip, as if you were pointing at it
    sound = false,       -- a soft sound when something comes into reach
    range = 20,          -- how far away (yards) things are picked out
    arc = 1,             -- in front of you: 0 a narrow cone, 1 wide, 2 all round
    hard = false,        -- the reach as a hard limit, not held to each thing's own distance
    cvars = {},          -- the game's own settings before ours (FrogLib's CVar), for putting back
}

ns.Print = FrogLib.Util.Printer("FrogInteract", "c0a060")

local ANY = (Enum.SoftTargetEnableFlags and Enum.SoftTargetEnableFlags.Any) or 3
local function Flag(on) return on and 1 or 0 end

-- The game's settings, from ours.
local function GameSettings()
    local db = ns.db
    local settings = {
        softTargetInteract = ANY, -- the Interact key works with a mouse and keyboard, not only a gamepad
        SoftTargetIconInteract = Flag(db.npcIcons),
        SoftTargetIconGameObject = Flag(db.objectIcons),
        SoftTargetLowPriorityIcons = Flag(db.lowPriority),
        SoftTargetNameplateInteract = Flag(db.names),
        SoftTargetNameplateSize = db.nameSize,
        SoftTargetTooltipInteract = Flag(db.tooltip),
        softTargettingInteractKeySound = Flag(db.sound),
        SoftTargetInteractRange = db.range,
        SoftTargetInteractArc = db.arc,
    }
    if db.hard then settings.SoftTargetInteractRangeIsHard = 1 end
    return settings
end

local warnedNoKey

function ns.Refresh()
    if not ns.db then return end
    FrogLib.CVar.Want("FrogInteract", 10, ns.db.enabled and GameSettings() or nil)
    if ns.db.enabled and not warnedNoKey and not GetBindingKey("INTERACTTARGET") then
        warnedNoKey = true
        ns.Print("bind a key to Interact with Target (Options > Keybindings > Targeting) to use what's marked.")
    end
end

-- What's picked out is read when asked (a unit: its name; an object has no unit, so it can't be named here), rather
-- than following every soft target change all session for this one line.
function ns.Status()
    local key = GetBindingKey("INTERACTTARGET")
    local exists = FrogLib.Safe(UnitExists("softinteract"))
    local name = exists and (FrogLib.Safe(UnitName("softinteract")) or "something") or nil
    ns.Print(string.format("%s; Interact on %s; picked out now: %s; reach %s yards, cone %s.",
        ns.db.enabled and "on" or "off", key or "no key", name or "nothing (or an object, which can't be named)",
        tostring(GetCVar("SoftTargetInteractRange")), tostring(GetCVar("SoftTargetInteractArc"))))
end

local loader = CreateFrame("Frame")
loader:RegisterEvent("ADDON_LOADED")
loader:RegisterEvent("PLAYER_LOGIN")
loader:SetScript("OnEvent", function(_, event, ...)
    if event == "ADDON_LOADED" and ... == ADDON then
        FrogInteractDB = FrogInteractDB or {}
        FrogLib.Util.CopyDefaults(ns.defaults, FrogInteractDB)
        ns.db = FrogInteractDB
        FrogLib.CVar.Register("FrogInteract", ns.db.cvars)
    elseif event == "PLAYER_LOGIN" then
        ns.Refresh()
    end
end)

SLASH_FROGINTERACT1 = "/fi"
SLASH_FROGINTERACT2 = "/froginteract"
SlashCmdList.FROGINTERACT = function(input)
    local command = strtrim(input or ""):lower()
    if command == "on" or command == "off" then
        ns.db.enabled = command == "on"
        ns.Refresh()
        ns.Print(ns.db.enabled and "on." or "off: the game's own settings are back.")
    elseif command == "status" then
        ns.Status()
    else
        ns.ToggleConfig()
    end
end

function FrogInteract_OnCompartmentClick() ns.ToggleConfig() end
