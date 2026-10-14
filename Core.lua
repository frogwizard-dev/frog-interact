local ADDON, ns = ...

-- FrogInteract: the game's Interact key, made to work well with a mouse and keyboard. The game
-- already picks out what's in front of you to interact with (its "soft target": an NPC, a chest,
-- ore, a herb, a mailbox, a fishing bobber) and can mark it with an icon and its name; these are
-- its own settings, put together and kept on. Your Interact key (Options > Keybindings) then uses
-- whatever's marked.
-- The settings go through FrogLib's CVar (layer 10): FrogFish's fishing ones sit on top while a
-- pole's on, and yours come back when FrogInteract is turned off or removed.

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
local function B(on) return on and 1 or 0 end

-- What the game's settings should be, from ours.
local function Values()
    local db = ns.db
    local values = {
        softTargetInteract = ANY, -- the Interact key works with a mouse and keyboard, not just a gamepad
        SoftTargetIconInteract = B(db.npcIcons),
        SoftTargetIconGameObject = B(db.objectIcons),
        SoftTargetLowPriorityIcons = B(db.lowPriority),
        SoftTargetNameplateInteract = B(db.names),
        SoftTargetNameplateSize = db.nameSize,
        SoftTargetTooltipInteract = B(db.tooltip),
        softTargettingInteractKeySound = B(db.sound),
        SoftTargetInteractRange = db.range,
        SoftTargetInteractArc = db.arc,
    }
    if db.hard then values.SoftTargetInteractRangeIsHard = 1 end
    return values
end

local keylessSaid

function ns.Refresh()
    if not ns.db then return end
    FrogLib.CVar.Want("FrogInteract", 10, ns.db.enabled and Values() or nil)
    if ns.db.enabled and not keylessSaid and not GetBindingKey("INTERACTTARGET") then
        keylessSaid = true
        ns.Print("bind a key to Interact with Target (Options > Keybindings > Targeting) to use what's marked.")
    end
end

-- What's picked out now: the game says when it changes (its GUID: an object isn't a unit).
local current

function ns.Status()
    local key = GetBindingKey("INTERACTTARGET")
    local name
    if current and not FrogLib.issecret(current) and current ~= "" then
        name = FrogLib.Safe(UnitName("softinteract"))
            or (current:match("^GameObject") and "an object" or "something")
    end
    ns.Print(string.format("%s; Interact on %s; picked out now: %s; reach %s yards, cone %s.",
        ns.db.enabled and "on" or "off", key or "no key", name or "nothing",
        tostring(GetCVar("SoftTargetInteractRange")), tostring(GetCVar("SoftTargetInteractArc"))))
end

local loader = CreateFrame("Frame")
loader:RegisterEvent("ADDON_LOADED")
loader:RegisterEvent("PLAYER_LOGIN")
pcall(loader.RegisterEvent, loader, "PLAYER_SOFT_INTERACT_CHANGED")
loader:SetScript("OnEvent", function(_, event, arg1, arg2)
    if event == "ADDON_LOADED" and arg1 == ADDON then
        FrogInteractDB = FrogInteractDB or {}
        FrogLib.Util.CopyDefaults(ns.defaults, FrogInteractDB)
        ns.db = FrogInteractDB
        FrogLib.CVar.Register("FrogInteract", ns.db.cvars)
    elseif event == "PLAYER_LOGIN" then
        ns.Refresh()
    elseif event == "PLAYER_SOFT_INTERACT_CHANGED" then
        current = arg2
    end
end)

SLASH_FROGINTERACT1 = "/fi"
SLASH_FROGINTERACT2 = "/froginteract"
SlashCmdList.FROGINTERACT = function(msg)
    msg = strtrim(msg or ""):lower()
    if msg == "on" or msg == "off" then
        ns.db.enabled = msg == "on"
        ns.Refresh()
        ns.Print(ns.db.enabled and "on." or "off: the game's own settings are back.")
    elseif msg == "status" then
        ns.Status()
    else
        ns.ToggleConfig()
    end
end

function FrogInteract_OnCompartmentClick() ns.ToggleConfig() end
