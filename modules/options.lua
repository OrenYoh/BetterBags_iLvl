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
local refreshButton

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
        refreshButton:Enable()
    end)
end

--- Options panel
-----------------------------
addon.options = function()
    return {
        iLvlOptions = {
            name = function()
                addon.frame:CreateDescription(L["OPTIONS_DESC"], { top = 20 })

                config.configFrame:AddSlider({
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

                addon.frame:CreateCheckbox({
                    title = L["OPTIONS_INCLUDE_JUNK"],
                    getValue = function(_)
                        return addon.db.includeJunk
                    end,
                    setValue = function(ctx, value)
                        addon.db.includeJunk = value
                        refreshCategory(ctx)
                    end
                })

                refreshButton = addon.frame:CreateButton({
                    title = L["OPTIONS_REFRESH"],
                    align = "CENTER",
                    disabled = true,
                    onClick = function()
                        refreshButton:Disable()
                        ConsoleExec("reloadui")
                    end
                })
            end
        }
    }
end
