-- Create a frame to handle events
local frame = CreateFrame("Frame")

-- Settings storage
local LootSoundDB = {
    playForQuality = {
        [0] = true,  -- Poor
        [1] = true,  -- Common
        [2] = true,  -- Uncommon
        [3] = true,  -- Rare
        [4] = true,  -- Epic
        [5] = true   -- Legendary
    }
}

-- Create settings panel
local settingsFrame = CreateFrame("Frame", "LootSoundSettingsFrame", UIParent, "BasicFrameTemplateWithInset")
settingsFrame:SetSize(300, 300)
settingsFrame:SetPoint("CENTER")
settingsFrame:Hide()

-- Add title text
settingsFrame.title = settingsFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
settingsFrame.title:SetPoint("TOP", 0, -5)
settingsFrame.title:SetText("LootSound Settings")

-- Add description text
local descriptionText = settingsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
descriptionText:SetPoint("TOPLEFT", 20, -40)
descriptionText:SetText("Enable LootSound for...")

-- Helper function to create checkboxes
local function CreateQualityCheckbox(parent, quality, yOffset)
    local checkbox = CreateFrame("CheckButton", nil, parent, "ChatConfigCheckButtonTemplate")
    checkbox:SetPoint("TOPLEFT", 20, yOffset)
    
    local qualityColors = {
        [0] = "9d9d9d", -- Poor (Gray)
        [1] = "ffffff", -- Common (White)
        [2] = "1eff00", -- Uncommon (Green)
        [3] = "0070dd", -- Rare (Blue)
        [4] = "a335ee", -- Epic (Purple)
        [5] = "ff8000"  -- Legendary (Orange)
    }
    
    local qualityNames = {
        [0] = "Poor",
        [1] = "Common",
        [2] = "Uncommon",
        [3] = "Rare",
        [4] = "Epic",
        [5] = "Legendary"
    }
    
    local text = checkbox:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    text:SetPoint("LEFT", checkbox, "RIGHT", 8, 0)
    text:SetText("|cff" .. qualityColors[quality] .. qualityNames[quality] .. "|r Items")
    
    checkbox:SetChecked(LootSoundDB.playForQuality[quality])
    checkbox:SetScript("OnClick", function(self)
        LootSoundDB.playForQuality[quality] = self:GetChecked()
    end)
    
    return checkbox
end

-- Create checkboxes for each quality
local startY = -60
local spacing = -25
settingsFrame.checkboxes = {
    CreateQualityCheckbox(settingsFrame, 5, startY + spacing * 0),  -- Legendary
    CreateQualityCheckbox(settingsFrame, 4, startY + spacing * 1),  -- Epic
    CreateQualityCheckbox(settingsFrame, 3, startY + spacing * 2),  -- Rare
    CreateQualityCheckbox(settingsFrame, 2, startY + spacing * 3),  -- Uncommon
    CreateQualityCheckbox(settingsFrame, 1, startY + spacing * 4),  -- Common
    CreateQualityCheckbox(settingsFrame, 0, startY + spacing * 5)   -- Poor
}

-- Register slash command
SLASH_LOOTSOUND1 = "/ls"
SlashCmdList["LOOTSOUND"] = function(msg)
    settingsFrame:SetShown(not settingsFrame:IsShown())
end

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
                
                -- Play sound only if enabled for this quality
                if quality and LootSoundDB.playForQuality[quality] then
                    PlaySoundFile(CUSTOM_SOUND_PATH .. ".ogg", "Master")
                    -- Break after first item to avoid multiple sounds at once
                    break
                end
            end
        end
    end
end) 