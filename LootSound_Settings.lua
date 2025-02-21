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
settingsFrame:SetSize(300, 460)  -- Reduced height slightly
settingsFrame:SetPoint("CENTER")
settingsFrame:Hide()

-- Add title text
settingsFrame.title = settingsFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
settingsFrame.title:SetPoint("TOP", 0, -5)
settingsFrame.title:SetText("LootSound Settings")

-- Create tab system
settingsFrame.Tabs = {}
for i = 1, 2 do
    local tab = CreateFrame("Button", "LootSoundSettingsFrameTab"..i, settingsFrame, "CharacterFrameTabButtonTemplate")
    tab:SetID(i)
    tab:Show()
    settingsFrame.Tabs[i] = tab
    
    if i == 1 then
        tab:SetPoint("BOTTOMLEFT", settingsFrame, "BOTTOMLEFT", 6, -30)
        tab:SetText("General")
    else
        tab:SetPoint("LEFT", settingsFrame.Tabs[i-1], "RIGHT", -16, 0)
        tab:SetText("Chat Settings")
    end
end

-- Create General Settings Panel
settingsFrame.generalPanel = CreateFrame("Frame", nil, settingsFrame)
settingsFrame.generalPanel:SetPoint("TOPLEFT", 10, -25)
settingsFrame.generalPanel:SetPoint("BOTTOMRIGHT", -10, 10)
settingsFrame.generalPanel:Show()

-- Create Chat Settings Panel
settingsFrame.chatPanel = CreateFrame("Frame", nil, settingsFrame)
settingsFrame.chatPanel:SetPoint("TOPLEFT", 10, -25)
settingsFrame.chatPanel:SetPoint("BOTTOMRIGHT", -10, 10)
settingsFrame.chatPanel:Hide()

-- Initialize tab system
PanelTemplates_SetNumTabs(settingsFrame, 2)
PanelTemplates_SetTab(settingsFrame, 1)

-- Tab click handler
settingsFrame.Tabs[1]:SetScript("OnClick", function()
    PanelTemplates_SetTab(settingsFrame, 1)
    settingsFrame.generalPanel:Show()
    settingsFrame.chatPanel:Hide()
end)

settingsFrame.Tabs[2]:SetScript("OnClick", function()
    PanelTemplates_SetTab(settingsFrame, 2)
    settingsFrame.generalPanel:Hide()
    settingsFrame.chatPanel:Show()
end)

-- Add global enable/disable toggle (General Panel)
local enableCheckbox = CreateFrame("CheckButton", nil, settingsFrame.generalPanel, "ChatConfigCheckButtonTemplate")
enableCheckbox:SetPoint("TOPLEFT", 15, -15)
enableCheckbox:SetChecked(LootSoundDB.enabled)
enableCheckbox:SetScript("OnClick", function(self)
    LootSoundDB.enabled = self:GetChecked()
end)

local enableText = enableCheckbox:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
enableText:SetPoint("LEFT", enableCheckbox, "RIGHT", 8, 0)
enableText:SetText("Enable LootSound")

-- Add sound selection (General Panel)
local soundLabel = settingsFrame.generalPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
soundLabel:SetPoint("TOPLEFT", 15, -50)
soundLabel:SetText("Select Sound:")

-- Sound selection dropdown
local soundDropdown = CreateFrame("Frame", "LootSoundSoundDropdown", settingsFrame.generalPanel, "UIDropDownMenuTemplate")
soundDropdown:SetPoint("TOPLEFT", 25, -70)

local function InitializeSoundDropdown(self, level)
    local info = UIDropDownMenu_CreateInfo()
    
    info.func = function(self)
        LootSoundDB.selectedSound = self.value
        UIDropDownMenu_SetText(soundDropdown, self:GetText())
        -- Play the selected sound as preview
        local sound = LOOTSOUND_SOUNDS[self.value]
        if sound then
            PlaySoundFile(sound.path .. ".ogg", "Master")
        end
    end
    
    -- Add each available sound to the dropdown
    for soundId, soundInfo in pairs(LOOTSOUND_SOUNDS) do
        info.text = soundInfo.name
        info.value = soundId
        info.checked = LootSoundDB.selectedSound == soundId
        UIDropDownMenu_AddButton(info)
    end
end

UIDropDownMenu_Initialize(soundDropdown, InitializeSoundDropdown)
UIDropDownMenu_SetWidth(soundDropdown, 150)
-- Set initial text
local initialSound = LOOTSOUND_SOUNDS[LootSoundDB.selectedSound]
UIDropDownMenu_SetText(soundDropdown, initialSound and initialSound.name or "Oh My God")

-- Add trigger type settings (General Panel)
local triggerLabel = settingsFrame.generalPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
triggerLabel:SetPoint("TOPLEFT", 15, -115)
triggerLabel:SetText("Trigger LootSound On:")

-- Regular loot checkbox
local regularLootCheckbox = CreateFrame("CheckButton", nil, settingsFrame.generalPanel, "ChatConfigCheckButtonTemplate")
regularLootCheckbox:SetPoint("TOPLEFT", 25, -135)
regularLootCheckbox:SetChecked(LootSoundDB.triggers.regularLoot)
regularLootCheckbox:SetScript("OnClick", function(self)
    LootSoundDB.triggers.regularLoot = self:GetChecked()
end)

local regularLootText = regularLootCheckbox:CreateFontString(nil, "ARTWORK", "GameFontNormal")
regularLootText:SetPoint("LEFT", regularLootCheckbox, "RIGHT", 8, 0)
regularLootText:SetText("Regular Loot")

-- Roll loot checkbox
local rollLootCheckbox = CreateFrame("CheckButton", nil, settingsFrame.generalPanel, "ChatConfigCheckButtonTemplate")
rollLootCheckbox:SetPoint("TOPLEFT", 25, -160)
rollLootCheckbox:SetChecked(LootSoundDB.triggers.rollLoot)
rollLootCheckbox:SetScript("OnClick", function(self)
    LootSoundDB.triggers.rollLoot = self:GetChecked()
end)

local rollLootText = rollLootCheckbox:CreateFontString(nil, "ARTWORK", "GameFontNormal")
rollLootText:SetPoint("LEFT", rollLootCheckbox, "RIGHT", 8, 0)
rollLootText:SetText("Group Loot Rolls")

-- Add quality settings description
local descriptionText = settingsFrame.generalPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
descriptionText:SetPoint("TOPLEFT", 15, -205)
descriptionText:SetText("Enable LootSound for...")

-- Helper function to create checkboxes
local function CreateQualityCheckbox(parent, quality, yOffset)
    local checkbox = CreateFrame("CheckButton", nil, parent, "ChatConfigCheckButtonTemplate")
    checkbox:SetPoint("TOPLEFT", 25, yOffset)  -- Increased indent
    
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
local startY = -225
local spacing = -25
settingsFrame.checkboxes = {
    CreateQualityCheckbox(settingsFrame.generalPanel, 5, startY + spacing * 0),  -- Legendary
    CreateQualityCheckbox(settingsFrame.generalPanel, 4, startY + spacing * 1),  -- Epic
    CreateQualityCheckbox(settingsFrame.generalPanel, 3, startY + spacing * 2),  -- Rare
    CreateQualityCheckbox(settingsFrame.generalPanel, 2, startY + spacing * 3),  -- Uncommon
    CreateQualityCheckbox(settingsFrame.generalPanel, 1, startY + spacing * 4),  -- Common
    CreateQualityCheckbox(settingsFrame.generalPanel, 0, startY + spacing * 5)   -- Poor
}

-- Chat Settings Panel Content
local chatMessageLabel = settingsFrame.chatPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
chatMessageLabel:SetPoint("TOPLEFT", 15, -15)
chatMessageLabel:SetText("Chat Message Settings")

-- Chat message enable checkbox
local chatMessageCheckbox = CreateFrame("CheckButton", nil, settingsFrame.chatPanel, "ChatConfigCheckButtonTemplate")
chatMessageCheckbox:SetPoint("TOPLEFT", 15, -50)
chatMessageCheckbox:SetChecked(LootSoundDB.triggers.chatMessage.enabled)
chatMessageCheckbox:SetScript("OnClick", function(self)
    LootSoundDB.triggers.chatMessage.enabled = self:GetChecked()
end)

local chatMessageText = chatMessageCheckbox:CreateFontString(nil, "ARTWORK", "GameFontNormal")
chatMessageText:SetPoint("LEFT", chatMessageCheckbox, "RIGHT", 8, 0)
chatMessageText:SetText("Enable Chat Trigger")

-- Message input label
local messageLabel = settingsFrame.chatPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
messageLabel:SetPoint("TOPLEFT", 15, -90)
messageLabel:SetText("Trigger Message:")

-- Create EditBox for message input
local editBox = CreateFrame("EditBox", nil, settingsFrame.chatPanel, "InputBoxTemplate")
editBox:SetPoint("TOPLEFT", 25, -110)
editBox:SetSize(200, 20)
editBox:SetAutoFocus(false)
editBox:SetText(LootSoundDB.triggers.chatMessage.message)
editBox:SetScript("OnEnterPressed", function(self)
    self:ClearFocus()
end)
editBox:SetScript("OnTextChanged", function(self)
    LootSoundDB.triggers.chatMessage.message = self:GetText()
end)

-- Match type label
local matchTypeLabel = settingsFrame.chatPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
matchTypeLabel:SetPoint("TOPLEFT", 15, -150)
matchTypeLabel:SetText("Match Type:")

-- Match type dropdown
local matchTypeDropdown = CreateFrame("Frame", "LootSoundMatchTypeDropdown", settingsFrame.chatPanel, "UIDropDownMenuTemplate")
matchTypeDropdown:SetPoint("TOPLEFT", 25, -170)

local function InitializeMatchTypeDropdown(self, level)
    local info = UIDropDownMenu_CreateInfo()
    
    info.func = function(self)
        LootSoundDB.triggers.chatMessage.matchType = self.value
        UIDropDownMenu_SetText(matchTypeDropdown, self:GetText())
    end
    
    info.text = "Contains"
    info.value = "contains"
    info.checked = LootSoundDB.triggers.chatMessage.matchType == "contains"
    UIDropDownMenu_AddButton(info)
    
    info.text = "Exact Match"
    info.value = "exact"
    info.checked = LootSoundDB.triggers.chatMessage.matchType == "exact"
    UIDropDownMenu_AddButton(info)
end

UIDropDownMenu_Initialize(matchTypeDropdown, InitializeMatchTypeDropdown)
UIDropDownMenu_SetWidth(matchTypeDropdown, 100)
UIDropDownMenu_SetText(matchTypeDropdown, LootSoundDB.triggers.chatMessage.matchType == "exact" and "Exact Match" or "Contains")

-- Register slash command
SLASH_LOOTSOUND1 = "/ls"
SlashCmdList["LOOTSOUND"] = function(msg)
    settingsFrame:SetShown(not settingsFrame:IsShown())
end 