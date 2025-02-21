-- Create a frame to handle events
local frame = CreateFrame("Frame")

-- Settings storage (will be populated from settings file)
LootSoundDB = {
    enabled = true,  -- Global enable/disable toggle
    selectedSound = "ohmygod",  -- Currently selected sound
    playForQuality = {
        [0] = true,  -- Poor
        [1] = true,  -- Common
        [2] = true,  -- Uncommon
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

-- Constants for item quality
local ITEM_QUALITY_POOR = 0      -- Gray
local ITEM_QUALITY_COMMON = 1    -- White
local ITEM_QUALITY_UNCOMMON = 2  -- Green
local ITEM_QUALITY_RARE = 3      -- Blue
local ITEM_QUALITY_EPIC = 4      -- Purple
local ITEM_QUALITY_LEGENDARY = 5  -- Orange

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
    -- Add new sounds here following the same format:
    -- soundId = { name = "Display Name", path = "Path/To/Sound" }
}

-- Helper function to play the selected sound
local function PlaySelectedSound()
    local sound = SOUNDS[LootSoundDB.selectedSound] or SOUNDS.ohmygod
    PlaySoundFile(sound.path .. ".ogg", "Master")
end

-- Register for events
frame:RegisterEvent("LOOT_READY")
frame:RegisterEvent("START_LOOT_ROLL")
frame:RegisterEvent("CHAT_MSG_SYSTEM")
frame:RegisterEvent("CHAT_MSG_SAY")
frame:RegisterEvent("CHAT_MSG_YELL")
frame:RegisterEvent("CHAT_MSG_PARTY")
frame:RegisterEvent("CHAT_MSG_PARTY_LEADER")
frame:RegisterEvent("CHAT_MSG_RAID")
frame:RegisterEvent("CHAT_MSG_RAID_LEADER")

-- Function to handle events
frame:SetScript("OnEvent", function(self, event, ...)
    -- Check if addon is globally enabled
    if not LootSoundDB.enabled then return end
    
    -- Handle chat messages
    if event:find("CHAT_MSG_") and LootSoundDB.triggers.chatMessage.enabled and LootSoundDB.triggers.chatMessage.message ~= "" then
        local message = ...
        local triggerMessage = LootSoundDB.triggers.chatMessage.message
        
        -- Check if message matches our trigger
        local matches = false
        if LootSoundDB.triggers.chatMessage.matchType == "exact" then
            matches = message == triggerMessage
        else
            matches = message:lower():find(triggerMessage:lower(), 1, true) ~= nil
        end
        
        if matches then
            PlaySelectedSound()
            return
        end
    end
    
    if event == "START_LOOT_ROLL" and LootSoundDB.triggers.rollLoot then
        local rollID = ...
        if rollID then
            -- Get the item link from the roll ID
            local _, _, _, quality = GetLootRollItemInfo(rollID)
            
            -- Play sound if enabled for this quality
            if quality and LootSoundDB.playForQuality[quality] then
                PlaySelectedSound()
            end
        end
    elseif event == "LOOT_READY" and LootSoundDB.triggers.regularLoot then
        -- Get the number of loot items
        local numItems = GetNumLootItems()
        
        -- Check each loot item
        for i = 1, numItems do
            local itemLink = GetLootSlotLink(i)
            if itemLink then
                -- Get the item quality
                local _, _, quality = GetItemInfo(itemLink)
                
                -- Play sound if enabled for this quality
                if quality and LootSoundDB.playForQuality[quality] then
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