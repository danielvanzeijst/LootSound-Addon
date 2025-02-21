-- Create a frame to handle events
local frame = CreateFrame("Frame")

-- Register for the loot event
frame:RegisterEvent("LOOT_READY")

-- Constants for item quality
local ITEM_QUALITY_POOR = 0      -- Gray
local ITEM_QUALITY_COMMON = 1    -- White
local ITEM_QUALITY_UNCOMMON = 2  -- Green
local ITEM_QUALITY_RARE = 3      -- Blue
local ITEM_QUALITY_EPIC = 4      -- Purple
local ITEM_QUALITY_LEGENDARY = 5  -- Orange

-- Register our custom sound
local CUSTOM_SOUND_PATH = "Interface\\AddOns\\LootSound\\sounds\\ohmygod"

-- Function to handle the loot event
frame:SetScript("OnEvent", function(self, event, ...)
    if event == "LOOT_READY" then
        -- Get the number of loot items
        local numItems = GetNumLootItems()
        
        -- Check each loot item
        for i = 1, numItems do
            local itemLink = GetLootSlotLink(i)
            if itemLink then
                -- Get the item quality
                local _, _, quality = GetItemInfo(itemLink)
                
                -- Play sound for any item quality (as long as we got valid item info)
                if quality then
                    PlaySoundFile(CUSTOM_SOUND_PATH .. ".ogg", "Master")
                    -- Break after first item to avoid multiple sounds at once
                    break
                end
            end
        end
    end
end) 