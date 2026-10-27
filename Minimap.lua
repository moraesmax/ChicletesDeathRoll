-- Chiclete's Death Roll - minimap button
local _, ns = ...
local M = {}
ns.Minimap = M

local function UpdatePosition()
    local b = M.button
    if not b then return end
    local angle = math.rad(ns.db.minimapAngle or 215)
    local radius = (Minimap:GetWidth() / 2) + 5
    b:ClearAllPoints()
    b:SetPoint("CENTER", Minimap, "CENTER", math.cos(angle) * radius, math.sin(angle) * radius)
end

local function OnDragUpdate()
    local mx, my = Minimap:GetCenter()
    local px, py = GetCursorPosition()
    local scale = Minimap:GetEffectiveScale()
    px, py = px / scale, py / scale
    ns.db.minimapAngle = math.deg(math.atan2(py - my, px - mx))
    UpdatePosition()
end

function M.Build()
    if M.button then return end
    local b = CreateFrame("Button", "ChicletesDeathRollMinimapButton", Minimap)
    b:SetSize(31, 31)
    b:SetFrameStrata("MEDIUM")
    b:SetFrameLevel(8)
    b:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    b:RegisterForDrag("LeftButton")
    b:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

    local icon = b:CreateTexture(nil, "ARTWORK")
    icon:SetTexture(ns.ICON)
    icon:SetSize(21, 21)
    icon:SetPoint("TOPLEFT", 5, -5)

    local border = b:CreateTexture(nil, "OVERLAY")
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    border:SetSize(53, 53)
    border:SetPoint("TOPLEFT")

    b:SetScript("OnClick", function(_, button)
        if button == "RightButton" then ns.UI.Show(4) else ns.UI.Toggle() end
    end)
    b:SetScript("OnDragStart", function(self) self:SetScript("OnUpdate", OnDragUpdate) end)
    b:SetScript("OnDragStop", function(self) self:SetScript("OnUpdate", nil) end)
    b:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:AddLine("Chiclete's Death Roll", 0.949, 0.788, 0.298)
        local d = ns.duel
        if d and d.state == "active" then
            GameTooltip:AddLine(("vs %s - max %s - %s"):format(ns.Short(d.opp), ns.Num(d.max),
                d.turn == "me" and "your turn" or "their turn"), 1, 1, 1)
        end
        GameTooltip:AddLine("Left-click: open window", 0.8, 0.8, 0.8)
        GameTooltip:AddLine("Right-click: options", 0.8, 0.8, 0.8)
        GameTooltip:AddLine("Drag: move button", 0.8, 0.8, 0.8)
        GameTooltip:Show()
    end)
    b:SetScript("OnLeave", function() GameTooltip:Hide() end)

    M.button = b
    UpdatePosition()
    M.Apply()
end

function M.Apply()
    if M.button then M.button:SetShown(ns.db.settings.minimap) end
end
