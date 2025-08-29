-- Thanks to wyeen on Curse

if(GetLocale() ~= 'zhCN') then
    return
end

local _, ns = ...
local L = ns.L

L["CATEGORY_NAME"] = "低等级";
L["OPTIONS_DESC"] = "选择此类别的 iLvl 阈值（所有 iLvl 严格低于此值的项目都将归入此类别）。一旦更改值，可能需要重新加载 UI。"
L["OPTIONS_INCLUDE_JUNK"] = "将质量较差的物品归入此类别";
L["OPTIONS_REFRESH"] = "重载UI";
L["OPTIONS_RESET_DEFAULT"] = "恢复默认值";
L["OPTIONS_THRESHOLD"] = "iLvl 阈值（默认值：_default_）";
L["OPTIONS_THRESHOLD_ERROR"] = "请输入有效的 iLvl 阈值";
