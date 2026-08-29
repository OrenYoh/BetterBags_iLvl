local addonName, root = ...;
local L = root.L;

---@class BetterBags_iLvl: AceAddon
local addon = LibStub('AceAddon-3.0'):GetAddon(addonName)

--- BetterBags dependencies
-----------------------------
---@class BetterBags: AceAddon
local BetterBags = LibStub('AceAddon-3.0'):GetAddon("BetterBags")
---@class Categories: AceModule
local categories = BetterBags:GetModule('Categories')
---@class Config: AceModule
local config = BetterBags:GetModule('Config')
---@class Events: AceModule
local events = BetterBags:GetModule('Events')
-----------------------------

local thresholdError = false
local debounceTimer

local updateSavedVariables = function()
    BetterBags_iLvlDB = addon.db
end

local function refreshCategory(context)
    if debounceTimer then
        debounceTimer:Cancel()
    end

    -- We wait for the value not to be changed for 1 second before refreshing the categories
    debounceTimer = C_Timer.NewTimer(1, function()
        updateSavedVariables()
        categories:WipeCategory(L["CATEGORY_NAME"])
        events:SendMessage(context, 'bags/FullRefreshAll')
    end)
end

--- Options panel
-----------------------------
addon.options = {
    a = {
        name = function()
            config.configFrame.layout:AddInlineSubSection({
                title = L["CATEGORY_NAME"],
                description = L["OPTIONS_DESC"],
            })
        end
    },
    b = {
        name = function()
            addon.frame:CreateDescription(L["OPTIONS_DESC"])

            config.configFrame.layout:AddSlider({
                title = L["OPTIONS_THRESHOLD"]:gsub("_default_", addon.vars.defaultThreshold),
                min = 1,
                max = tonumber(addon.vars.maximumThreshold),
                step = 1,
                id = "ilvl_threshold",
                getValue = function(_)
                    return addon.db.threshold
                end,
                setValue = function(ctx, value)
                    if (tonumber(value)) then
                        thresholdError = false
                        addon.db.threshold = tostring(value)
                        refreshCategory(ctx)
                    else
                        thresholdError = true
                    end
                end,
            })
        end
    },
    c = {
        type = "toggle",
        name = L["OPTIONS_INCLUDE_JUNK"],
        get = function() return addon.db.includeJunk end,
        set = function(ctx, value)
            addon.db.includeJunk = value
            refreshCategory(ctx)
        end
    },
}
