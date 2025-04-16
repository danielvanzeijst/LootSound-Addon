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
settingsFrame:SetSize(300, 460)
settingsFrame:SetPoint("CENTER")
settingsFrame:Hide()

-- Make the frame movable
settingsFrame:SetMovable(true)
settingsFrame:EnableMouse(true)
settingsFrame:RegisterForDrag("LeftButton")
settingsFrame:SetScript("OnDragStart", settingsFrame.StartMoving)
settingsFrame:SetScript("OnDragStop", settingsFrame.StopMovingOrSizing)

-- Add title text
settingsFrame.title = settingsFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
settingsFrame.title:SetPoint("TOP", 0, -5)
settingsFrame.title:SetText("LootSound Settings")

-- Create tab system (Structure only)
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
PanelTemplates_SetNumTabs(settingsFrame, 2)
PanelTemplates_SetTab(settingsFrame, 1) -- Default to first tab

-- Create Panels (Structure only)
settingsFrame.generalPanel = CreateFrame("Frame", nil, settingsFrame)
settingsFrame.generalPanel:SetPoint("TOPLEFT", 10, -25)
settingsFrame.generalPanel:SetPoint("BOTTOMRIGHT", -10, 10)
settingsFrame.generalPanel:Show()
settingsFrame.chatPanel = CreateFrame("Frame", nil, settingsFrame)
settingsFrame.chatPanel:SetPoint("TOPLEFT", 10, -25)
settingsFrame.chatPanel:SetPoint("BOTTOMRIGHT", -10, 10)
settingsFrame.chatPanel:Hide()

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

-- Create UI Elements (Structure only, population deferred)

-- General Panel Elements
local enableCheckbox = CreateFrame("CheckButton", nil, settingsFrame.generalPanel, "ChatConfigCheckButtonTemplate")
enableCheckbox:SetPoint("TOPLEFT", 15, -15)
local enableText = enableCheckbox:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
enableText:SetPoint("LEFT", enableCheckbox, "RIGHT", 8, 0)
enableText:SetText("Enable LootSound")

local soundLabel = settingsFrame.generalPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
soundLabel:SetPoint("TOPLEFT", 15, -50)
soundLabel:SetText("Select Sound:")
local soundDropdown = CreateFrame("Frame", "LootSoundSoundDropdown", settingsFrame.generalPanel, "UIDropDownMenuTemplate")
soundDropdown:SetPoint("TOPLEFT", 25, -70)
UIDropDownMenu_SetWidth(soundDropdown, 150)

local triggerLabel = settingsFrame.generalPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
triggerLabel:SetPoint("TOPLEFT", 15, -115)
triggerLabel:SetText("Trigger LootSound On:")
local regularLootCheckbox = CreateFrame("CheckButton", nil, settingsFrame.generalPanel, "ChatConfigCheckButtonTemplate")
regularLootCheckbox:SetPoint("TOPLEFT", 25, -135)
local regularLootText = regularLootCheckbox:CreateFontString(nil, "ARTWORK", "GameFontNormal")
regularLootText:SetPoint("LEFT", regularLootCheckbox, "RIGHT", 8, 0)
regularLootText:SetText("Regular Loot")
local rollLootCheckbox = CreateFrame("CheckButton", nil, settingsFrame.generalPanel, "ChatConfigCheckButtonTemplate")
rollLootCheckbox:SetPoint("TOPLEFT", 25, -160)
local rollLootText = rollLootCheckbox:CreateFontString(nil, "ARTWORK", "GameFontNormal")
rollLootText:SetPoint("LEFT", rollLootCheckbox, "RIGHT", 8, 0)
rollLootText:SetText("Group Loot Rolls")

local descriptionText = settingsFrame.generalPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
descriptionText:SetPoint("TOPLEFT", 15, -205)
descriptionText:SetText("Enable LootSound for...")

settingsFrame.checkboxes = {}
local startY = -225
local spacing = -25
for quality = 5, 0, -1 do
    local checkbox = CreateFrame("CheckButton", nil, settingsFrame.generalPanel, "ChatConfigCheckButtonTemplate")
    checkbox:SetPoint("TOPLEFT", 25, startY + spacing * (5 - quality))
    local text = checkbox:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    text:SetPoint("LEFT", checkbox, "RIGHT", 8, 0)
    text:SetText("|cff" .. QUALITY_COLORS[quality] .. QUALITY_NAMES[quality] .. "|r Items")
    settingsFrame.checkboxes[quality] = checkbox -- Store checkbox reference
end

-- Chat Panel Elements
local chatMessageLabel = settingsFrame.chatPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
chatMessageLabel:SetPoint("TOPLEFT", 15, -15)
chatMessageLabel:SetText("Chat Message Settings")
local chatMessageCheckbox = CreateFrame("CheckButton", nil, settingsFrame.chatPanel, "ChatConfigCheckButtonTemplate")
chatMessageCheckbox:SetPoint("TOPLEFT", 15, -50)
local chatMessageText = chatMessageCheckbox:CreateFontString(nil, "ARTWORK", "GameFontNormal")
chatMessageText:SetPoint("LEFT", chatMessageCheckbox, "RIGHT", 8, 0)
chatMessageText:SetText("Enable Chat Trigger")

local messageLabel = settingsFrame.chatPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
messageLabel:SetPoint("TOPLEFT", 15, -90)
messageLabel:SetText("Trigger Message:")
local editBox = CreateFrame("EditBox", nil, settingsFrame.chatPanel, "InputBoxTemplate")
editBox:SetPoint("TOPLEFT", 25, -110)
editBox:SetSize(200, 20)
editBox:SetAutoFocus(false)

local matchTypeLabel = settingsFrame.chatPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
matchTypeLabel:SetPoint("TOPLEFT", 15, -150)
matchTypeLabel:SetText("Match Type:")
local matchTypeDropdown = CreateFrame("Frame", "LootSoundMatchTypeDropdown", settingsFrame.chatPanel, "UIDropDownMenuTemplate")
matchTypeDropdown:SetPoint("TOPLEFT", 25, -170)
UIDropDownMenu_SetWidth(matchTypeDropdown, 150)

-- Function to Refresh/Populate UI elements with current settings
local function RefreshSettingsUI()
    if not _G.LootSoundDB then return end -- Safety check

    -- General Panel Population
    enableCheckbox:SetChecked(_G.LootSoundDB.enabled)

    local function InitializeSoundDropdown(self, level)
        local info = UIDropDownMenu_CreateInfo()
        info.func = function(self)
            _G.LootSoundDB.selectedSound = self.value
            _G.LootSoundSaveSettings()
            UIDropDownMenu_SetText(soundDropdown, self:GetText())
            local sound = LOOTSOUND_SOUNDS[self.value]
            if sound then PlaySoundFile(sound.path .. ".ogg", "Master") end
        end
        for soundId, soundInfo in pairs(LOOTSOUND_SOUNDS) do
            info.text = soundInfo.name
            info.value = soundId
            info.checked = _G.LootSoundDB.selectedSound == soundId
            UIDropDownMenu_AddButton(info)
        end
    end
    UIDropDownMenu_Initialize(soundDropdown, InitializeSoundDropdown)
    local initialSound = LOOTSOUND_SOUNDS[_G.LootSoundDB.selectedSound]
    UIDropDownMenu_SetText(soundDropdown, initialSound and initialSound.name or "Oh My God")

    regularLootCheckbox:SetChecked(_G.LootSoundDB.triggers.regularLoot)
    rollLootCheckbox:SetChecked(_G.LootSoundDB.triggers.rollLoot)

    for quality = 0, 5 do
        if settingsFrame.checkboxes[quality] then
            settingsFrame.checkboxes[quality]:SetChecked(_G.LootSoundDB.playForQuality[quality])
        end
    end

    -- Chat Panel Population
    chatMessageCheckbox:SetChecked(_G.LootSoundDB.triggers.chatMessage.enabled)
    editBox:SetText(_G.LootSoundDB.triggers.chatMessage.message)

    local function InitializeMatchTypeDropdown(self, level)
        local info = UIDropDownMenu_CreateInfo()
        info.func = function(self)
            _G.LootSoundDB.triggers.chatMessage.matchType = self.value
            _G.LootSoundSaveSettings()
            UIDropDownMenu_SetText(matchTypeDropdown, self:GetText())
        end
        info.text = "Contains"
        info.value = "contains"
        info.checked = _G.LootSoundDB.triggers.chatMessage.matchType == "contains"
        UIDropDownMenu_AddButton(info)
        info.text = "Exact Match"
        info.value = "exact"
        info.checked = _G.LootSoundDB.triggers.chatMessage.matchType == "exact"
        UIDropDownMenu_AddButton(info)
    end
    UIDropDownMenu_Initialize(matchTypeDropdown, InitializeMatchTypeDropdown)
    UIDropDownMenu_SetText(matchTypeDropdown, _G.LootSoundDB.triggers.chatMessage.matchType == "exact" and "Exact Match" or "Contains")

    -- Set Scripts (moved here to ensure they have access to populated _G.LootSoundDB)
    enableCheckbox:SetScript("OnClick", function(self)
        _G.LootSoundDB.enabled = self:GetChecked()
        _G.LootSoundSaveSettings()
    end)
    regularLootCheckbox:SetScript("OnClick", function(self)
        _G.LootSoundDB.triggers.regularLoot = self:GetChecked()
        _G.LootSoundSaveSettings()
    end)
    rollLootCheckbox:SetScript("OnClick", function(self)
        _G.LootSoundDB.triggers.rollLoot = self:GetChecked()
        _G.LootSoundSaveSettings()
    end)
    for quality = 0, 5 do
        if settingsFrame.checkboxes[quality] then
            settingsFrame.checkboxes[quality]:SetScript("OnClick", function(self)
                _G.LootSoundDB.playForQuality[quality] = self:GetChecked()
                _G.LootSoundSaveSettings()
            end)
        end
    end
    chatMessageCheckbox:SetScript("OnClick", function(self)
        _G.LootSoundDB.triggers.chatMessage.enabled = self:GetChecked()
        _G.LootSoundSaveSettings()
    end)
    editBox:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
    editBox:SetScript("OnTextChanged", function(self)
        _G.LootSoundDB.triggers.chatMessage.message = self:GetText()
        _G.LootSoundSaveSettings()
    end)
end

-- Make the refresh function global so it can be called from LootSound.lua
_G.LootSound_RefreshSettingsUI = RefreshSettingsUI

-- Register slash command (now handled in LootSound.lua)
-- SLASH_LOOTSOUND1 = "/ls"
-- SlashCmdList["LOOTSOUND"] = function(msg)
--     settingsFrame:SetShown(not settingsFrame:IsShown())
-- end 