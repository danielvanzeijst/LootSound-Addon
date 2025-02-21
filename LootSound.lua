-- Create a frame to handle events
local frame = CreateFrame("Frame")

-- Settings storage (will be populated from settings file)
LootSoundDB = {
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
        rollLoot = true
    }
}

-- Constants for item quality
local ITEM_QUALITY_POOR = 0      -- Gray
local ITEM_QUALITY_COMMON = 1    -- White
local ITEM_QUALITY_UNCOMMON = 2  -- Green
local ITEM_QUALITY_RARE = 3      -- Blue
local ITEM_QUALITY_EPIC = 4      -- Purple
local ITEM_QUALITY_LEGENDARY = 5  -- Orange

-- Register our custom sound
local CUSTOM_SOUND_PATH = "Interface\\AddOns\\LootSound\\sounds\\ohmygod"

-- Register for both events
frame:RegisterEvent("LOOT_READY")
frame:RegisterEvent("START_LOOT_ROLL")

-- Function to handle events
frame:SetScript("OnEvent", function(self, event, ...)
    if event == "START_LOOT_ROLL" and LootSoundDB.triggers.rollLoot then
        local rollID = ...
        if rollID then
            -- Get the item link from the roll ID
            local _, _, _, quality = GetLootRollItemInfo(rollID)
            
            -- Play sound if enabled for this quality
            if quality and LootSoundDB.playForQuality[quality] then
                PlaySoundFile(CUSTOM_SOUND_PATH .. ".ogg", "Master")
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
                    PlaySoundFile(CUSTOM_SOUND_PATH .. ".ogg", "Master")
                    -- Break after first item to avoid multiple sounds at once
                    break
                end
            end
        end
    end
end) 