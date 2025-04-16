local addonName, addonTable = ...

-- Create a frame to handle addon events
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("VARIABLES_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGOUT")

-- Default settings
local DEFAULT_SETTINGS = {
    enabled = true,  -- Global enable/disable toggle
    selectedSound = "ohmygod",  -- Currently selected sound
    playForQuality = {
        [0] = false,  -- Poor
        [1] = false,  -- Common
        [2] = false,  -- Uncommon
        [3] = true,  -- Rare
        [4] = true,  -- Epic
        [5] = true   -- Legendary
    },
    triggers = {
        regularLoot = true,
        rollLoot = true,
        chatMessage = {
            enabled = false,
            message = "",
            matchType = "contains" -- can be "exact" or "contains"
        }
    }
}

-- Helper function to deep merge default settings into saved settings
local function MergeDefaults(saved, defaults)
    for k, v in pairs(defaults) do
        if type(v) == "table" then
            if type(saved[k]) ~= "table" then
                saved[k] = {}
            end
            MergeDefaults(saved[k], v) -- Recursively merge nested tables
        elseif saved[k] == nil then
            saved[k] = v
        end
    end
end

-- Function to initialize or load saved settings
local function InitializeSettings()
    if not _G.LootSoundDB then
        _G.LootSoundDB = CopyTable(DEFAULT_SETTINGS) -- Use a copy for the first time
    else
        -- Merge defaults into existing saved variables
        MergeDefaults(_G.LootSoundDB, DEFAULT_SETTINGS)
    end
    -- Settings are now loaded and merged
end

-- Function to save settings (called by UI)
local function SaveSettings()
    -- Simply ensure the global variable reference points to the table
    -- WoW handles the actual saving on logout/reload if declared in TOC
    _G.LootSoundDB = _G.LootSoundDB 
end

-- Handle VARIABLES_LOADED event
eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "VARIABLES_LOADED" then
        InitializeSettings()
        -- Settings are loaded, now populate the UI if it exists
        if _G.LootSound_RefreshSettingsUI then
            _G.LootSound_RefreshSettingsUI()
        end
        -- Unregister this event once variables are loaded
        self:UnregisterEvent("VARIABLES_LOADED")
    elseif event == "PLAYER_LOGOUT" then
        -- Explicitly ensure saving on logout (though usually automatic)
         SaveSettings()
    end
end)

-- Create the main event handling frame (for loot, chat, etc.)
local mainFrame = CreateFrame("Frame")

-- Constants for item quality
local ITEM_QUALITY_POOR = 0      -- Gray
local ITEM_QUALITY_COMMON = 1    -- White
local ITEM_QUALITY_UNCOMMON = 2  -- Green
local ITEM_QUALITY_RARE = 3      -- Blue
local ITEM_QUALITY_EPIC = 4      -- Purple
local ITEM_QUALITY_LEGENDARY = 5  -- Orange

-- Function to get file name without extension
local function GetFileNameWithoutExtension(path)
    return path:match("(.+)%..+$")
end

-- Function to scan for custom sound files
local function ScanCustomSounds()
    local customSounds = {}
    local customDir = "Interface\\AddOns\\LootSound\\sounds\\custom"
    
    -- Since we can't directly scan the directory in WoW, we'll rely on the TOC file
    -- to tell us which files exist. The files will be listed in the TOC with patterns
    -- like sounds\custom\*.ogg and sounds\custom\*.mp3
    
    -- For now, we'll just return an empty table and let users add their sounds
    -- by manually adding them to the SOUNDS table below
    return customSounds
end

-- Available sounds configuration
local SOUNDS = {
    ohmygod = {
        name = "Oh My God",
        path = "Interface\\AddOns\\LootSound\\sounds\\ohmygod"
    },
    vineboom = {
        name = "Vine Boom",
        path = "Interface\\AddOns\\LootSound\\sounds\\vineboom"
    }
}

-- Add custom sounds to the SOUNDS table
local customSounds = ScanCustomSounds()
for soundId, soundInfo in pairs(customSounds) do
    SOUNDS[soundId] = soundInfo
end

-- Helper function to play the selected sound
local function PlaySelectedSound()
    -- Ensure settings are loaded before trying to access them
    if not _G.LootSoundDB then return end 
    local sound = SOUNDS[_G.LootSoundDB.selectedSound] or SOUNDS.ohmygod
    PlaySoundFile(sound.path .. ".ogg", "Master")
end

-- Register for game events
mainFrame:RegisterEvent("LOOT_READY")
mainFrame:RegisterEvent("START_LOOT_ROLL")
mainFrame:RegisterEvent("CHAT_MSG_SYSTEM")
mainFrame:RegisterEvent("CHAT_MSG_SAY")
mainFrame:RegisterEvent("CHAT_MSG_YELL")
mainFrame:RegisterEvent("CHAT_MSG_PARTY")
mainFrame:RegisterEvent("CHAT_MSG_PARTY_LEADER")
mainFrame:RegisterEvent("CHAT_MSG_RAID")
mainFrame:RegisterEvent("CHAT_MSG_RAID_LEADER")

-- Function to handle game events
mainFrame:SetScript("OnEvent", function(self, event, ...)
    -- Ensure settings are loaded before processing events
    if not _G.LootSoundDB then return end 

    -- Check if addon is globally enabled
    if not _G.LootSoundDB.enabled then return end
    
    -- Handle chat messages
    if event:find("CHAT_MSG_") and _G.LootSoundDB.triggers.chatMessage.enabled and _G.LootSoundDB.triggers.chatMessage.message ~= "" then
        local message = ...
        local triggerMessage = _G.LootSoundDB.triggers.chatMessage.message
        
        -- Check if message matches our trigger
        local matches = false
        if _G.LootSoundDB.triggers.chatMessage.matchType == "exact" then
            matches = message == triggerMessage
        else
            matches = message:lower():find(triggerMessage:lower(), 1, true) ~= nil
        end
        
        if matches then
            PlaySelectedSound()
            return
        end
    end
    
    if event == "START_LOOT_ROLL" and _G.LootSoundDB.triggers.rollLoot then
        local rollID = ...
        if rollID then
            -- Get the item link from the roll ID
            local _, _, _, quality = GetLootRollItemInfo(rollID)
            
            -- Play sound if enabled for this quality
            if quality and _G.LootSoundDB.playForQuality[quality] then
                PlaySelectedSound()
            end
        end
    elseif event == "LOOT_READY" and _G.LootSoundDB.triggers.regularLoot then
        -- Get the number of loot items
        local numItems = GetNumLootItems()
        
        -- Check each loot item
        for i = 1, numItems do
            local itemLink = GetLootSlotLink(i)
            if itemLink then
                -- Get the item quality
                local _, _, quality = GetItemInfo(itemLink)
                
                -- Play sound if enabled for this quality
                if quality and _G.LootSoundDB.playForQuality[quality] then
                    PlaySelectedSound()
                    -- Break after first item to avoid multiple sounds at once
                    break
                end
            end
        end
    end
end)

-- Make sounds available to settings
_G.LOOTSOUND_SOUNDS = SOUNDS

-- Register slash command
SLASH_LOOTSOUND1 = "/ls"
SLASH_LOOTSOUND2 = "/lootsound"
SlashCmdList["LOOTSOUND"] = function(msg)
    if not _G.LootSoundDB then 
        print("|cFFFF0000LootSound:|r Settings not loaded yet. Please wait a moment.")
        return 
    end
    
    if LootSoundSettingsFrame then
        if LootSoundSettingsFrame:IsShown() then
            LootSoundSettingsFrame:Hide()
        else
            -- Ensure the settings frame reflects the current state before showing
            if _G.LootSound_RefreshSettingsUI then
                 _G.LootSound_RefreshSettingsUI()
            end
            LootSoundSettingsFrame:Show() 
        end
    else
        print("|cFFFF0000LootSound:|r Settings frame not found. Please reload your UI.")
    end
end

-- Make save function available globally
_G.LootSoundSaveSettings = SaveSettings 