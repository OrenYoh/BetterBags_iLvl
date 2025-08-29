local addonName, root = ...;
local L = root.L;
local _G = _G

---@class BetterBags_Legendary: AceModule
local addon = LibStub("AceAddon-3.0"):NewAddon(root, addonName, 'AceHook-3.0')

--- BetterBags dependencies
-----------------------------
---@class BetterBags: AceAddon
local BetterBags = LibStub('AceAddon-3.0'):GetAddon("BetterBags")
assert(BetterBags, addonName .. " requires BetterBags")
---@class Categories: AceModule
local categories = BetterBags:GetModule('Categories')
---@class Config: AceModule
local config = BetterBags:GetModule('Config')
---@class Context: AceModule
local context = BetterBags:GetModule('Context')
-----------------------------

--- Default config
-----------------------------
addon.context = context:New(L["CATEGORY_NAME"] .. "_Event")

-- Default values, set to current season dungeon ilvl and max MM ilvl
local defaultThreshold = "639"
local maximumThreshold = "723"

if (_G.WOW_PROJECT_ID == _G.WOW_PROJECT_CLASSIC) then
    defaultThreshold = "60"
    maximumThreshold = "100"
elseif (_G.WOW_PROJECT_ID == _G.WOW_PROJECT_BURNING_CRUSADE_CLASSIC) then
    defaultThreshold = "120"
    maximumThreshold = "175"
elseif (_G.WOW_PROJECT_ID == _G.WOW_PROJECT_WRATH_CLASSIC) then
    defaultThreshold = "200"
    maximumThreshold = "284"
elseif (_G.WOW_PROJECT_ID == _G.WOW_PROJECT_CATACLYSM_CLASSIC) then
    defaultThreshold = "346"
    maximumThreshold = "416"
elseif (_G.WOW_PROJECT_ID == _G.WOW_PROJECT_MISTS_CLASSIC) then
    defaultThreshold = "410"
    maximumThreshold = "509"
end

addon.db = {
    threshold = defaultThreshold,
    includeJunk = true,
}

addon.vars = {
    defaultThreshold = defaultThreshold,
    maximumThreshold = maximumThreshold,
}
-----------------------------

--- Addon core
-----------------------------
addon.eventFrame = CreateFrame("Frame", addonName .. "EventFrame", UIParent)
addon.eventFrame:RegisterEvent("ADDON_LOADED")
addon.eventFrame:SetScript("OnEvent", function(_, event, ...)
	if event == "ADDON_LOADED" then
        local name = ...;
        if name == addonName then
            addon:OnReady()
        end
    end
end)

function addon:OnReady()
    if (type(BetterBags_iLvlDB) ~= "table") then BetterBags_iLvlDB = {} end

    -- Update local db with saved variables
    local db = BetterBags_iLvlDB
    for key in pairs(addon.db) do
        --  If our option is not present, set default value
        if (db[key] == nil) then db[key] = addon.db[key] end
    end
    addon.db = db

    -- Clean category on load
    categories:WipeCategory(addon.context:Copy(), L["CATEGORY_NAME"])

    -- Add addon config to BetterBags
    config:AddPluginConfig(L["CATEGORY_NAME"], addon.options())

    -- Create addon category if it doesn't already exist
    local categoryAlreadyExists = categories:GetCategoryByName(L["CATEGORY_NAME"])

    if not categoryAlreadyExists then
        categories:CreateCategory({
            name = L["CATEGORY_NAME"],
            save = true,
            itemList = {},
        })
    end
end

