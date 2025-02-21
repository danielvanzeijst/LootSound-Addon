-- Quality colors and names
local QUALITY_COLORS = {
    [0] = "9d9d9d", -- Poor (Gray)
    [1] = "ffffff", -- Common (White)
    [2] = "1eff00", -- Uncommon (Green)
    [3] = "0070dd", -- Rare (Blue)
    [4] = "a335ee", -- Epic (Purple)
    [5] = "ff8000"  -- Legendary (Orange)
}

local QUALITY_NAMES = {
    [0] = "Poor",
    [1] = "Common",
    [2] = "Uncommon",
    [3] = "Rare",
    [4] = "Epic",
    [5] = "Legendary"
}

-- Create settings panel
local settingsFrame = CreateFrame("Frame", "LootSoundSettingsFrame", UIParent, "BasicFrameTemplateWithInset")
settingsFrame:SetSize(300, 350)
settingsFrame:SetPoint("CENTER")
settingsFrame:Hide()

-- Add title text
settingsFrame.title = settingsFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
settingsFrame.title:SetPoint("TOP", 0, -5)
settingsFrame.title:SetText("LootSound Settings")

-- Add trigger type settings
local triggerLabel = settingsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
triggerLabel:SetPoint("TOPLEFT", 20, -40)
triggerLabel:SetText("Trigger LootSound On:")

-- Regular loot checkbox
local regularLootCheckbox = CreateFrame("CheckButton", nil, settingsFrame, "ChatConfigCheckButtonTemplate")
regularLootCheckbox:SetPoint("TOPLEFT", 20, -60)
regularLootCheckbox:SetChecked(LootSoundDB.triggers.regularLoot)
regularLootCheckbox:SetScript("OnClick", function(self)
    LootSoundDB.triggers.regularLoot = self:GetChecked()
end)

local regularLootText = regularLootCheckbox:CreateFontString(nil, "ARTWORK", "GameFontNormal")
regularLootText:SetPoint("LEFT", regularLootCheckbox, "RIGHT", 8, 0)
regularLootText:SetText("Regular Loot")

-- Roll loot checkbox
local rollLootCheckbox = CreateFrame("CheckButton", nil, settingsFrame, "ChatConfigCheckButtonTemplate")
rollLootCheckbox:SetPoint("TOPLEFT", 20, -85)
rollLootCheckbox:SetChecked(LootSoundDB.triggers.rollLoot)
rollLootCheckbox:SetScript("OnClick", function(self)
    LootSoundDB.triggers.rollLoot = self:GetChecked()
end)

local rollLootText = rollLootCheckbox:CreateFontString(nil, "ARTWORK", "GameFontNormal")
rollLootText:SetPoint("LEFT", rollLootCheckbox, "RIGHT", 8, 0)
rollLootText:SetText("Group Loot Rolls")

-- Add quality settings description
local descriptionText = settingsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
descriptionText:SetPoint("TOPLEFT", 20, -130)
descriptionText:SetText("Enable LootSound for...")

-- Helper function to create checkboxes
local function CreateQualityCheckbox(parent, quality, yOffset)
    local checkbox = CreateFrame("CheckButton", nil, parent, "ChatConfigCheckButtonTemplate")
    checkbox:SetPoint("TOPLEFT", 20, yOffset)
    
    local text = checkbox:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    text:SetPoint("LEFT", checkbox, "RIGHT", 8, 0)
    text:SetText("|cff" .. QUALITY_COLORS[quality] .. QUALITY_NAMES[quality] .. "|r Items")
    
    checkbox:SetChecked(LootSoundDB.playForQuality[quality])
    checkbox:SetScript("OnClick", function(self)
        LootSoundDB.playForQuality[quality] = self:GetChecked()
    end)
    
    return checkbox
end

-- Create checkboxes for each quality
local startY = -150
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