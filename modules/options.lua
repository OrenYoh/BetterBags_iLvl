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
---@class Events: AceModule
local events = BetterBags:GetModule('Events')
-----------------------------

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
        categories:WipeCategory(context:Copy(), L["CATEGORY_NAME"])
        events:SendMessage(context, 'bags/FullRefreshAll')
    end)
end
-- Exposed so BetterBags_iLvl.lua can trigger a refresh after recomputing the
-- dynamic threshold on login/reload (PLAYER_ENTERING_WORLD fires well after
-- this file has loaded, so addon.refreshCategory is guaranteed to be set).
addon.refreshCategory = refreshCategory

--- Options panel
-----------------------------
-- Plain AceConfig options: BetterBags builds the plugin's settings page from
-- them and reads names and hidden states again after every change, so the
-- dynamic toggle's label and which threshold control shows stay current.
addon.options = {
    description = {
        type = "description",
        order = 1,
        name = L["OPTIONS_DESC"],
    },
    threshold = {
        type = "range",
        order = 4,
        width = "full",
        name = L["OPTIONS_THRESHOLD"]:gsub("_default_", addon.vars.defaultThreshold),
        min = 1,
        max = tonumber(addon.vars.maximumThreshold),
        step = 1,
        hidden = function() return addon.db.useDynamicThreshold end,
        get = function() return tonumber(addon.db.threshold) or tonumber(addon.vars.defaultThreshold) end,
        set = function(_, value)
            addon.db.threshold = tostring(math.floor(value))
            refreshCategory(addon.context:Copy())
        end,
    },
    includeJunk = {
        type = "toggle",
        order = 5,
        width = "full",
        name = L["OPTIONS_INCLUDE_JUNK"],
        get = function() return addon.db.includeJunk end,
        set = function(_, value)
            addon.db.includeJunk = value
            refreshCategory(addon.context:Copy())
        end,
    },
}

if addon.vars.isRetail then
    addon.options.dynamicThreshold = {
        type = "toggle",
        order = 2,
        width = "full",
        name = function()
            if addon.db.useDynamicThreshold then
                return (L["OPTIONS_DYNAMIC_TOGGLE_ACTIVE"]:gsub("_value_", addon.db.threshold))
            end
            return L["OPTIONS_DYNAMIC_TOGGLE"]
        end,
        desc = L["OPTIONS_DYNAMIC_TOGGLE_DESC"],
        get = function() return addon.db.useDynamicThreshold end,
        set = function(_, value)
            addon.db.useDynamicThreshold = value
            if value then
                addon.db.dynamicOffset = addon.vars.defaultDynamicOffset
                addon:UpdateDynamicThreshold()
            end
            updateSavedVariables()
        end,
    }

    addon.options.dynamicOffset = {
        type = "input",
        order = 3,
        width = "full",
        name = L["OPTIONS_DYNAMIC_OFFSET"]:gsub("_default_", addon.vars.defaultDynamicOffset),
        desc = L["OPTIONS_DYNAMIC_OFFSET_DESC"],
        hidden = function() return not addon.db.useDynamicThreshold end,
        get = function() return addon.db.dynamicOffset end,
        validate = function(_, value)
            local offset = tonumber(value)
            if not offset or offset <= 0 then
                return L["OPTIONS_THRESHOLD_ERROR"]
            end
            return true
        end,
        set = function(_, value)
            local offset = math.min(tonumber(value), tonumber(addon.vars.maximumThreshold))
            addon.db.dynamicOffset = tostring(math.floor(offset))
            addon:UpdateDynamicThreshold()
        end,
    }

    addon.options.useMaxItemLevel = {
        type = "toggle",
        order = 6,
        width = "full",
        name = L["OPTIONS_USE_MAX_ILVL"],
        desc = L["OPTIONS_USE_MAX_ILVL_DESC"],
        get = function() return addon.db.useMaxItemLevel end,
        set = function(_, value)
            addon.db.useMaxItemLevel = value
            refreshCategory(addon.context:Copy())
        end,
    }
end
