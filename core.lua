local fontConfig = {
    font = 'Fonts\\ARIALN.ttf',
    size = 8,
};

local sunderArmorLocalName = GetSpellInfo(7405);
local mod = CreateFrame('frame', 'SunderTrack', UIParent);

mod.isMinimized = false;

mod.isMinimized = false;

mod.title = mod:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge");
mod.title:SetPoint("TOPLEFT", mod, "TOPLEFT", 0, 0);
mod.title:SetPoint("TOPRIGHT", mod, "TOPRIGHT", 0, 0);
mod.title:SetJustifyH("CENTER");
mod.title:SetText("Sunders");

mod.minimapButton = CreateFrame("Button", "SunderTrackMinimapButton", Minimap);
mod.minimapButton:SetSize(32, 32);
mod.minimapButton:SetFrameStrata("MEDIUM");
mod.minimapButton:SetPoint("TOPLEFT", Minimap, "TOPLEFT", -5, 0);

mod.minimapButton:SetNormalTexture("Interface\\AddOns\\SunderTrack\\sunder.tga");
mod.minimapButton:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight");

mod.minimapButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT");
    GameTooltip:AddLine("Sunder Track");
    GameTooltip:AddLine("Left-click to show/hide", 1, 1, 1);
    GameTooltip:AddLine("Right-click to toggle move anchor", 1, 1, 1);
    GameTooltip:Show();
end);

mod.minimapButton:SetScript("OnLeave", function()
    GameTooltip:Hide();
end);

mod.minimapButton:RegisterForClicks("LeftButtonUp", "RightButtonUp");
mod.minimapButton:SetScript("OnClick", function(self, button)
    if button == "LeftButton" then
        if mod:IsShown() then
            mod:Hide();
            mod.title:Hide();
        else
            mod:Show();
            mod.title:Show();
        end
    elseif button == "RightButton" then
        mod:toggleMoveable();
    end
end);

mod:SetWidth(150);
mod:SetHeight(2000);
mod:SetPoint('TOP', UIParent, 'TOP', 0, -100);


mod:SetMovable(true);
mod:RegisterForDrag('LeftButton');
mod:SetScript('OnDragStart', mod.StartMoving);
mod:SetScript('OnDragStop', mod.StopMovingOrSizing);

mod.tex = mod:CreateTexture('ARTWORK');
mod.tex:SetAllPoints();
mod.tex:SetTexture(1.0, 0.5, 0);
mod.tex:SetAlpha(0);

mod.names = mod:CreateFontString(nil,'ARTWORK');
mod.names:SetFont(fontConfig.font, fontConfig.size, fontConfig.outline);
mod.names:SetPoint('TOPLEFT', mod, 'TOPLEFT', 4, -24);
mod.names:SetWidth(mod:GetWidth() / 2 - 8);
mod.names:SetJustifyV('TOP');
mod.names:SetJustifyH('LEFT');

mod.values = mod:CreateFontString(nil,'ARTWORK');
mod.values:SetFont(fontConfig.font, fontConfig.size, fontConfig.outline);
mod.values:SetPoint('TOPRIGHT', mod, 'TOPRIGHT', -4, -24);
mod.values:SetWidth(mod:GetWidth() / 2 - 8);
mod.values:SetJustifyV('TOP');
mod.values:SetJustifyH('RIGHT');

mod:RegisterEvent("ZONE_CHANGED_NEW_AREA");

function mod:ZONE_CHANGED_NEW_AREA()
    self:reset();
end

function mod:reset()
    SunderTable = {};

    self:renderCasts();
end;

function mod:initializeWarriors()
    local numGroupMembers = GetNumGroupMembers();
    local isInRaid = IsInRaid();

    for i = 1, numGroupMembers do
        local unit = isInRaid and "raid"..i or "party"..i;
        if UnitExists(unit) and UnitClassBase(unit) == "WARRIOR" then
            local name = GetUnitName(unit, false);
            if name and not SunderTable[name] then
                SunderTable[name] = 0;
            end
        end
    end
end

function mod:renderCasts()
    local names = '';
    local values = '';

    local sunderTable = {};

    for k, v in pairs(SunderTable) do
        table.insert(sunderTable, {k, v});
    end

    table.sort(sunderTable, function (a, b)
        return a[2] > b[2];
    end);

    for k, v in ipairs(sunderTable) do
        names = names .. k .. '. ' .. v[1] .. '\n';
        values = values .. v[2] .. '\n';
    end

    self.names:SetText(names);
    self.values:SetText(values);

    local lineHeight = fontConfig.size + 2; 
    local numLines = #sunderTable;
    local extraPadding = 20; 
    local minHeight = 280;
    self:SetHeight(math.max(numLines * lineHeight + extraPadding, minHeight));
end

function mod:toggleMoveable()
    local willBeEnabled = not self:IsMouseClickEnabled();
    self:EnableMouse(willBeEnabled);

    if (willBeEnabled) then
        self.tex:SetAlpha(0.5);
    else
        self.tex:SetAlpha(0);
    end;
end;


function mod:addSunderCast(unitName)
    if (not SunderTable[unitName]) then
        SunderTable[unitName] = 0;
    end;

    SunderTable[unitName] = SunderTable[unitName] + 1;
end;

function mod:ADDON_LOADED(addon)
    self:UnregisterEvent('ADDON_LOADED');
    self:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED');

    self:init();
end;

function mod:COMBAT_LOG_EVENT_UNFILTERED()
    local _, subEvent, _, _, unitName = CombatLogGetCurrentEventInfo();
    local spellName = select(13, CombatLogGetCurrentEventInfo());

    if (subEvent ~= 'SPELL_CAST_SUCCESS') then
        return;
    end;

    if (spellName ~= sunderArmorLocalName) then
        return;
    end;

    local inParty = UnitInParty(unitName)
        and UnitIsPlayer(unitName)
        and UnitIsFriend("player", unitName);

    if (not inParty) then
        return;
    end;

    self:addSunderCast(unitName);
    self:renderCasts();
end;

function mod:syncGroupWarriors()
    local currentGroup = {};
    local numGroupMembers = GetNumGroupMembers();
    local isInRaid = IsInRaid();

    for i = 1, numGroupMembers do
        local unit = isInRaid and "raid"..i or "party"..i;
        if UnitExists(unit) and UnitClassBase(unit) == "WARRIOR" then
            local name = GetUnitName(unit, false); -- Exclude server names
            if name then
                currentGroup[name] = true;
                if not SunderTable[name] then
                    SunderTable[name] = 0;
                end
            end
        end
    end

    for name in pairs(SunderTable) do
        if not currentGroup[name] then
            SunderTable[name] = nil;
        end
    end
end

function mod:init()
    SunderTable = SunderTable or {};
    self:syncGroupWarriors();
    self:renderCasts();
end;

local function OnEvent(self, event, ...)
	if (self[event]) then
		return self[event](self, ...);
	end;
end;

mod:RegisterEvent("GROUP_ROSTER_UPDATE");
function mod:GROUP_ROSTER_UPDATE()
    self:initializeWarriors();
    self:renderCasts();
end

mod:RegisterEvent('ADDON_LOADED');
mod:SetScript('OnEvent', OnEvent);

SLASH_SUNDER1 = '/sunder';
SlashCmdList['SUNDER'] = function(msg)
    if (msg == 'reset') then
        mod:reset();
    else
        mod:toggleMoveable();
    end;
end;