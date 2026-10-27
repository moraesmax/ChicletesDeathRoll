-- Chiclete's Death Roll - interface
local _, ns = ...
local UI = {}
ns.UI = UI

------------------------------------------------------------------------
-- Look
------------------------------------------------------------------------
local C = {
    gold        = { 0.949, 0.788, 0.298 },
    text        = { 0.910, 0.894, 0.847 },
    soft        = { 0.812, 0.788, 0.722 },
    label       = { 0.659, 0.631, 0.565 },
    muted       = { 0.541, 0.522, 0.463 },
    green       = { 0.498, 0.816, 0.541 },
    red         = { 0.910, 0.541, 0.541 },
    bg          = { 0.086, 0.094, 0.114, 0.97 },
    header      = { 0.114, 0.106, 0.086, 1 },
    border      = { 0.290, 0.263, 0.208, 1 },
    line        = { 0.173, 0.165, 0.141, 1 },
    field       = { 0.055, 0.059, 0.071, 1 },
    fieldBorder = { 0.227, 0.247, 0.290, 1 },
    goldBorder  = { 0.420, 0.353, 0.165, 1 },
    row         = { 0.071, 0.075, 0.090, 1 },
}

local STYLES = {
    red      = { bg = { 0.541, 0.110, 0.110, 1 }, border = { 0.788, 0.290, 0.227, 1 }, text = { 1, 0.957, 0.878 }, title = true, size = 16 },
    gray     = { bg = { 0.137, 0.149, 0.176, 1 }, border = C.fieldBorder, text = C.text, size = 12 },
    selected = { bg = { 0.227, 0.188, 0.086, 1 }, border = { 0.949, 0.788, 0.298, 1 }, text = C.gold, size = 12 },
    ghost    = { bg = { 0, 0, 0, 0 }, border = { 0.353, 0.165, 0.165, 1 }, text = C.red, size = 11 },
    green    = { bg = { 0.122, 0.227, 0.133, 1 }, border = { 0.310, 0.604, 0.353, 1 }, text = { 0.847, 0.961, 0.863 }, size = 13 },
    close    = { bg = { 0.165, 0.078, 0.078, 1 }, border = C.border, text = { 0.910, 0.627, 0.627 }, size = 12 },
    tab      = { bg = { 0, 0, 0, 0 }, border = { 0, 0, 0, 0 }, text = C.label, size = 12 },
    tabOn    = { bg = { 0.137, 0.149, 0.176, 1 }, border = { 0, 0, 0, 0 }, text = C.gold, size = 12 },
}

local TITLE_FONT = "Fonts\\MORPHEUS.TTF"
local BODY_FONT  = STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF"
local WHITE      = "Interface\\Buttons\\WHITE8x8"
local COIN       = "|TInterface\\MoneyFrame\\UI-GoldIcon:0:0:2:0|t"
local BD1 = { bgFile = WHITE, edgeFile = WHITE, edgeSize = 1 }
local BD2 = { bgFile = WHITE, edgeFile = WHITE, edgeSize = 2 }
local W, PAD, IW = 380, 16, 348

local function Skin(f, bg, border, thick)
    f:SetBackdrop(thick and BD2 or BD1)
    f:SetBackdropColor(unpack(bg))
    f:SetBackdropBorderColor(unpack(border))
end

local function Text(parent, size, color, title, justify)
    local fs = parent:CreateFontString(nil, "OVERLAY")
    fs:SetFont(title and TITLE_FONT or BODY_FONT, size, "")
    fs:SetTextColor(unpack(color or C.text))
    fs:SetJustifyH(justify or "LEFT")
    return fs
end

local function SetColor(fs, color) fs:SetTextColor(unpack(color)) end

local function Label(parent, s)
    local fs = Text(parent, 10, C.label)
    fs:SetText(s:upper())
    return fs
end

local function Panel(parent, bg, border)
    local f = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    Skin(f, bg or C.field, border or C.line)
    return f
end

local function ApplyStyle(b, name)
    local s = STYLES[name]
    b.styleName = name
    Skin(b, s.bg, s.border)
    b.label:SetFont(s.title and TITLE_FONT or BODY_FONT, b.fontSize or s.size, "")
    b.label:SetTextColor(unpack(s.text))
end

local function Button(parent, w, h, text, style, onClick, fontSize)
    local b = CreateFrame("Button", nil, parent, "BackdropTemplate")
    b:SetSize(w, h)
    b.fontSize = fontSize
    b.label = b:CreateFontString(nil, "OVERLAY")
    b.label:SetPoint("CENTER")
    ApplyStyle(b, style or "gray")
    b.label:SetText(text)
    local hl = b:CreateTexture(nil, "HIGHLIGHT")
    hl:SetAllPoints()
    hl:SetColorTexture(1, 1, 1, 0.06)
    b:SetScript("OnEnable", function(self) self:SetAlpha(1) end)
    b:SetScript("OnDisable", function(self) self:SetAlpha(0.4) end)
    b:SetScript("OnClick", function(self, button)
        if self.onClick then self.onClick(self, button) end
        ns.FlushSay()
    end)
    b.onClick = onClick
    b.SetStyle = ApplyStyle
    b.SetLabel = function(self, t) self.label:SetText(t) end
    return b
end

local function Input(parent, w, h, size)
    local e = CreateFrame("EditBox", nil, parent, "BackdropTemplate")
    e:SetSize(w, h)
    Skin(e, C.field, C.fieldBorder)
    e:SetFont(BODY_FONT, size or 13, "")
    e:SetTextColor(unpack(C.text))
    e:SetTextInsets(8, 8, 0, 0)
    e:SetAutoFocus(false)
    e:SetMaxLetters(64)
    e:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    e:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
    return e
end

local function Check(parent, text, key)
    local cb = CreateFrame("CheckButton", nil, parent, "BackdropTemplate")
    cb:SetSize(16, 16)
    Skin(cb, C.field, C.fieldBorder)
    local t = cb:CreateTexture(nil, "OVERLAY")
    t:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
    t:SetSize(22, 22)
    t:SetPoint("CENTER")
    cb:SetCheckedTexture(t)
    cb.text = Text(cb, 12, C.soft)
    cb.text:SetPoint("LEFT", cb, "RIGHT", 8, 0)
    cb.text:SetText(text)
    cb:SetHitRectInsets(0, -(cb.text:GetStringWidth() + 10), 0, 0)
    cb:SetScript("OnClick", function(self)
        ns.db.settings[key] = self:GetChecked() and true or false
        UI.ApplySettings()
        ns.FlushSay()
    end)
    cb.Sync = function(self) self:SetChecked(ns.db.settings[key] and true or false) end
    UI.checks[#UI.checks + 1] = cb
    return cb
end

local function MakeDraggable(f, key)
    f:SetMovable(true)
    f:EnableMouse(true)
    f:SetClampedToScreen(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local p, _, rp, x, y = self:GetPoint()
        ns.db[key] = { p, rp, x, y }
    end)
end

local function RestorePoint(f, key, default)
    f:ClearAllPoints()
    local p = ns.db[key]
    if p then f:SetPoint(p[1], UIParent, p[2], p[3], p[4]) else f:SetPoint(unpack(default)) end
end

local function SignedGold(n)
    if n >= 0 then return "+" .. ns.Gold(n) end
    return "-" .. ns.Gold(-n)
end

local function Clock(sec)
    sec = math.max(0, math.floor(sec))
    return ("%d:%02d"):format(math.floor(sec / 60), sec % 60)
end

------------------------------------------------------------------------
-- Setup view
------------------------------------------------------------------------
local PRESETS = { { 5000, "5k" }, { 10000, "10k" }, { 20000, "20k" }, { 25000, "25k" }, { 50000, "50k" } }

local function BuildSetup(parent)
    local v = CreateFrame("Frame", nil, parent)
    v:SetAllPoints()
    local y = -14

    Label(v, "Opponent"):SetPoint("TOPLEFT", PAD, y)
    y = y - 16
    v.opp = Input(v, 244, 32)
    v.opp:SetPoint("TOPLEFT", PAD, y)
    v.opp:SetScript("OnTextChanged", function(self, user)
        if not user then return end
        UI.probeToken = (UI.probeToken or 0) + 1
        local token = UI.probeToken
        C_Timer.After(0.8, function()
            if token == UI.probeToken then ns.Probe(strtrim(self:GetText())) end
        end)
        UI.RefreshSetup()
    end)
    v.target = Button(v, 96, 32, "Use target", "gray", function()
        if not UnitExists("target") or not UnitIsPlayer("target") then
            v.err:SetText("Target a player first.")
            return
        end
        local name, realm = UnitName("target")
        if ns.IsSecret(name) then return end
        if realm and realm ~= "" and not ns.IsSecret(realm) then name = name .. "-" .. realm end
        v.opp:SetText(name)
        v.err:SetText("")
        ns.Probe(name)
        UI.RefreshSetup()
    end)
    v.target:SetPoint("TOPLEFT", PAD + 252, y)
    y = y - 38

    v.status = Text(v, 11, C.muted)
    v.status:SetPoint("TOPLEFT", PAD, y)
    v.status:SetWidth(IW)
    y = y - 15
    v.status2 = Text(v, 11, C.muted)
    v.status2:SetPoint("TOPLEFT", PAD, y)
    v.status2:SetWidth(IW)
    y = y - 24

    Label(v, "Starting roll = wager"):SetPoint("TOPLEFT", PAD, y)
    y = y - 16
    local box = Panel(v, C.field, C.goldBorder)
    box:SetSize(IW, 42)
    box:SetPoint("TOPLEFT", PAD, y)
    local coin = box:CreateTexture(nil, "ARTWORK")
    coin:SetTexture("Interface\\MoneyFrame\\UI-GoldIcon")
    coin:SetSize(16, 16)
    coin:SetPoint("LEFT", 12, 0)
    local suffix = Text(box, 12, C.muted)
    suffix:SetPoint("RIGHT", -12, 0)
    suffix:SetText("gold")
    v.amount = CreateFrame("EditBox", nil, box)
    v.amount:SetPoint("LEFT", coin, "RIGHT", 8, 0)
    v.amount:SetPoint("RIGHT", suffix, "LEFT", -8, 0)
    v.amount:SetHeight(32)
    v.amount:SetFont(TITLE_FONT, 20, "")
    v.amount:SetTextColor(unpack(C.gold))
    v.amount:SetAutoFocus(false)
    v.amount:SetMaxLetters(16)
    v.amount:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    v.amount:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
    v.amount:SetScript("OnTextChanged", function() UI.RefreshSetup() end)
    y = y - 48

    v.presets = {}
    for i, p in ipairs(PRESETS) do
        local b = Button(v, 64, 30, p[2], "gray", function()
            v.amount:SetText(ns.Num(p[1]))
            v.amount:ClearFocus()
        end)
        b:SetPoint("TOPLEFT", PAD + (i - 1) * 71, y)
        b.value = p[1]
        v.presets[i] = b
    end
    y = y - 36

    local hint = Text(v, 11, C.muted)
    hint:SetPoint("TOPLEFT", PAD, y)
    hint:SetText("Or type any amount. Loser pays this amount.")
    y = y - 24

    Label(v, "Who rolls first"):SetPoint("TOPLEFT", PAD, y)
    y = y - 16
    v.firstMe = Button(v, 174, 32, "Me", "selected", function() UI.firstMe = true; UI.RefreshSetup() end)
    v.firstMe:SetPoint("TOPLEFT", PAD, y)
    v.firstOpp = Button(v, 174, 32, "Opponent", "gray", function() UI.firstMe = false; UI.RefreshSetup() end)
    v.firstOpp:SetPoint("TOPLEFT", PAD + 174, y)
    y = y - 44

    v.announce = Check(v, "Announce in group chat (/i, /raid or /party)", "announce")
    v.announce:SetPoint("TOPLEFT", PAD, y)
    y = y - 30

    v.start = Button(v, IW, 44, "Start Duel", "red", function()
        local amount = ns.ParseAmount(v.amount:GetText())
        local ok, err = ns.StartChallenge(v.opp:GetText(), amount, UI.firstMe)
        v.err:SetText(ok and "" or err)
    end)
    v.start:SetPoint("TOPLEFT", PAD, y)
    y = y - 52

    v.err = Text(v, 11, C.red)
    v.err:SetPoint("TOPLEFT", PAD, y)
    v.err:SetWidth(IW)
    y = y - 18

    v.recLeft = Text(v, 11, C.muted)
    v.recLeft:SetPoint("TOPLEFT", PAD, y)
    v.recRight = Text(v, 11, C.muted, false, "RIGHT")
    v.recRight:SetPoint("TOPRIGHT", -PAD, y)
    return v
end

function UI.RefreshSetup()
    local v = UI.views and UI.views.setup
    if not v then return end
    local name = strtrim(v.opp:GetText() or "")

    if name == "" then
        SetColor(v.status, C.muted)
        v.status:SetText("Type a name or target a player.")
        v.status2:SetText("")
    else
        local st = ns.AddonStatus(name)
        if st == "yes" then
            SetColor(v.status, C.green)
            v.status:SetText("Addon detected - they'll get a challenge popup")
            v.status2:SetText("")
        elseif st == "checking" then
            SetColor(v.status, C.muted)
            v.status:SetText("Checking for the addon...")
            v.status2:SetText("")
        elseif st == "no" then
            SetColor(v.status, C.muted)
            v.status:SetText("No addon detected")
            v.status2:SetText("Challenge goes to chat, their first /roll starts it")
        else
            SetColor(v.status, C.muted)
            v.status:SetText("Not in your group or targeted")
            v.status2:SetText("Challenge goes to chat, their first /roll starts it")
        end
    end

    local amount = ns.ParseAmount(v.amount:GetText())
    for _, b in ipairs(v.presets) do
        b:SetStyle(amount == b.value and "selected" or "gray")
    end
    v.firstMe:SetStyle(UI.firstMe and "selected" or "gray")
    v.firstOpp:SetStyle(UI.firstMe and "gray" or "selected")
    v.announce:Sync()

    if name ~= "" then
        local w, l, net = ns.RecordVs(name)
        v.recLeft:SetText(("vs %s: |cff7fd08a%dW|r / |cffe88a8a%dL|r"):format(ns.Short(name), w, l))
        v.recRight:SetText(("Net: %s%s|r"):format(net >= 0 and "|cff7fd08a" or "|cffe88a8a", SignedGold(net)))
    else
        v.recLeft:SetText("")
        v.recRight:SetText("")
    end
end

------------------------------------------------------------------------
-- Active duel view
------------------------------------------------------------------------
local HISTORY_ROWS = 6

local function BuildActive(parent)
    local v = CreateFrame("Frame", nil, parent)
    v:SetAllPoints()

    v.vs = Text(v, 15, C.gold)
    v.vs:SetPoint("TOPLEFT", PAD, -14)
    v.vs:SetWidth(IW)
    v.sub = Text(v, 11, C.label)
    v.sub:SetPoint("TOPLEFT", PAD, -34)

    local maxPanel = Panel(v)
    maxPanel:SetSize(IW, 92)
    maxPanel:SetPoint("TOPLEFT", PAD, -54)
    local ml = Label(maxPanel, "Current max")
    ml:SetPoint("TOP", 0, -12)
    v.max = Text(maxPanel, 44, C.gold, true, "CENTER")
    v.max:SetPoint("CENTER", 0, -8)

    v.turn = Text(v, 13, C.green, false, "CENTER")
    v.turn:SetPoint("TOP", 0, -158)
    v.turn:SetWidth(IW)

    v.roll = Button(v, IW, 52, "Roll", "red", function() ns.DoRoll() end, 20)
    v.roll:SetPoint("TOPLEFT", PAD, -180)

    v.warn = Text(v, 11, C.red, false, "CENTER")
    v.warn:SetPoint("TOP", 0, -240)
    v.warn:SetWidth(IW)

    Label(v, "History"):SetPoint("TOPLEFT", PAD, -258)
    v.rows = {}
    for i = 1, HISTORY_ROWS do
        local r = CreateFrame("Frame", nil, v)
        r:SetSize(IW, 24)
        r:SetPoint("TOPLEFT", PAD, -274 - (i - 1) * 24)
        r.bg = r:CreateTexture(nil, "BACKGROUND")
        r.bg:SetAllPoints()
        r.bg:SetColorTexture(unpack(i % 2 == 0 and C.row or C.field))
        r.who = Text(r, 12, C.soft)
        r.who:SetPoint("LEFT", 10, 0)
        r.range = Text(r, 12, C.muted, false, "CENTER")
        r.range:SetPoint("CENTER")
        r.roll = Text(r, 12, C.text, false, "RIGHT")
        r.roll:SetPoint("RIGHT", -10, 0)
        v.rows[i] = r
    end

    local fy = -274 - HISTORY_ROWS * 24 - 10
    v.info = Text(v, 10, C.muted)
    v.info:SetPoint("TOPLEFT", PAD, fy - 2)
    v.info:SetWidth(128)
    v.endBtn = Button(v, 76, 28, "Cancel", "ghost", function() ns.EndDuel(true) end)
    v.endBtn:SetPoint("TOPRIGHT", -PAD, fy)
    v.nudge = Button(v, 60, 28, "Nudge", "gray", function() ns.Nudge() end, 11)
    v.nudge:SetPoint("RIGHT", v.endBtn, "LEFT", -6, 0)
    return v
end

function UI.RefreshActive()
    local v = UI.views.active
    local d = ns.duel
    if not d then return end
    local opp = ns.Short(d.opp)
    local s = ns.db.settings

    v.vs:SetText("Death Roll vs " .. opp)
    v.sub:SetText(("Wager %s  /  started at %s"):format(ns.Gold(d.amount), ns.Num(d.amount)))
    v.max:SetText(ns.Num(d.max))
    v.roll:SetLabel(("Roll 1 - %s"):format(ns.Num(d.max)))

    local showNudge = false
    if d.state == "pending" then
        SetColor(v.turn, C.muted)
        v.turn:SetText(("WAITING FOR %s TO ACCEPT (%ds)"):format(opp:upper(), math.max(0, (d.expires or 0) - time())))
        v.roll:Disable()
        v.endBtn:SetLabel("Cancel")
    else
        local myTurn = d.turn == "me"
        local idle = time() - (d.lastAction or time())
        if myTurn then
            SetColor(v.turn, C.green)
            v.turn:SetText("YOUR TURN")
        else
            SetColor(v.turn, C.muted)
            if idle >= 15 then
                v.turn:SetText(("WAITING FOR %s  (%s)"):format(opp:upper(), Clock(idle)))
            else
                v.turn:SetText(("WAITING FOR %s"):format(opp:upper()))
            end
            showNudge = idle >= s.nudgeAfter
        end
        local pending = d.rollPending and (GetTime() - d.rollPending) < 3
        v.roll:SetEnabled(myTurn and not pending)
        v.endBtn:SetLabel(#d.history == 0 and "Cancel" or "End duel")
    end
    v.nudge:SetShown(showNudge)
    v.nudge:SetEnabled(not d.nudged or (time() - d.nudged) > 20)

    if ns.warnUntil and GetTime() < ns.warnUntil then
        v.warn:SetText(ns.warnText or "")
    else
        v.warn:SetText("")
    end

    v.info:SetText(d.oppHasAddon and (opp .. " has the addon")
        or ("Reading " .. opp .. "'s /roll from chat"))

    local h = d.history
    local visible = d.state == "active" and HISTORY_ROWS - 1 or HISTORY_ROWS
    local first = math.max(1, #h - visible + 1)
    for i = 1, HISTORY_ROWS do
        local r = v.rows[i]
        local e = h[first + i - 1]
        if e then
            r.who:SetText(e.who == "me" and "You" or opp)
            r.range:SetText("1 - " .. ns.Num(e.max))
            r.roll:SetText(ns.Num(e.roll))
            SetColor(r.roll, e.roll == 1 and C.red or C.text)
        elseif i == #h - first + 2 and d.state == "active" then
            r.who:SetText(d.turn == "me" and "You" or opp)
            r.range:SetText("1 - " .. ns.Num(d.max))
            r.roll:SetText("...")
            SetColor(r.roll, C.muted)
        else
            r.who:SetText("")
            r.range:SetText("")
            r.roll:SetText("")
        end
    end
end

------------------------------------------------------------------------
-- Result view
------------------------------------------------------------------------
local function BuildResult(parent)
    local v = CreateFrame("Frame", nil, parent)
    v:SetAllPoints()

    v.icon = v:CreateTexture(nil, "ARTWORK")
    v.icon:SetTexture(ns.ICON)
    v.icon:SetSize(52, 52)
    v.icon:SetPoint("TOP", 0, -22)

    v.l1 = Text(v, 13, C.soft, false, "CENTER")
    v.l1:SetPoint("TOP", 0, -84)
    v.l1:SetWidth(IW)
    v.big = Text(v, 32, C.green, true, "CENTER")
    v.big:SetPoint("TOP", 0, -106)
    v.amt = Text(v, 20, C.gold, false, "CENTER")
    v.amt:SetPoint("TOP", 0, -150)
    v.sub = Text(v, 11, C.muted, false, "CENTER")
    v.sub:SetPoint("TOP", 0, -180)
    v.paid = Text(v, 12, C.green, false, "CENTER")
    v.paid:SetPoint("TOP", 0, -198)

    v.trade = Button(v, 170, 42, "Open trade", "gray", function()
        local d = ns.duel
        if not d then return end
        ns.OpenTrade(d.opp, d.result == "loss" and d.amount or nil)
    end, 13)
    v.trade:SetPoint("TOPLEFT", PAD, -226)
    v.rematch = Button(v, 170, 42, "Rematch", "red", function() ns.Rematch() end)
    v.rematch:SetPoint("TOPRIGHT", -PAD, -226)
    v.close = Button(v, IW, 30, "Back to setup", "gray", function() ns.ClearDuel() end)
    v.close:SetPoint("TOPLEFT", PAD, -276)

    v.recLeft = Text(v, 11, C.muted)
    v.recLeft:SetPoint("TOPLEFT", PAD, -322)
    v.recRight = Text(v, 11, C.muted, false, "RIGHT")
    v.recRight:SetPoint("TOPRIGHT", -PAD, -322)
    return v
end

function UI.RefreshResult()
    local v = UI.views.result
    local d = ns.duel
    if not d then return end
    local opp = ns.Short(d.opp)
    local last = d.history[#d.history]
    local lastRange = last and ("(1 - " .. ns.Num(last.max) .. ")") or ""
    local rolls = #d.history

    if d.result == "win" then
        v.l1:SetText(opp .. " rolled |cffe88a8a1|r " .. lastRange)
        v.big:SetText("You win")
        SetColor(v.big, C.green)
        v.sub:SetText(("%d rolls  /  %s owes you"):format(rolls, opp))
    else
        v.l1:SetText("You rolled |cffe88a8a1|r " .. lastRange)
        v.big:SetText("You lose")
        SetColor(v.big, C.red)
        v.sub:SetText(("%d rolls  /  you owe %s"):format(rolls, opp))
    end
    v.amt:SetText(COIN .. " " .. ns.Num(d.amount) .. " gold")

    local debt = ns.FindDebt(d.debtId)
    local paid = debt and debt.paid
    v.paid:SetText(paid and "Paid" or "")
    v.trade:SetEnabled(debt ~= nil and not paid)

    local w, l, net = ns.RecordVs(d.opp)
    v.recLeft:SetText(("vs %s: |cff7fd08a%dW|r / |cffe88a8a%dL|r"):format(opp, w, l))
    v.recRight:SetText(("Net: %s%s|r"):format(net >= 0 and "|cff7fd08a" or "|cffe88a8a", SignedGold(net)))
end

------------------------------------------------------------------------
-- Stats view
------------------------------------------------------------------------
local OPP_ROWS = 8

local function Tile(parent, label)
    local t = Panel(parent)
    t:SetSize(112, 50)
    local l = Text(t, 10, C.label)
    l:SetPoint("TOPLEFT", 10, -9)
    l:SetText(label)
    t.value = Text(t, 14, C.text)
    t.value:SetPoint("BOTTOMLEFT", 10, 9)
    return t
end

local function BuildStats(parent)
    local v = CreateFrame("Frame", nil, parent)
    v:SetAllPoints()

    Label(v, "Net gold"):SetPoint("TOPLEFT", PAD, -14)
    v.net = Text(v, 28, C.green, true)
    v.net:SetPoint("TOPLEFT", PAD, -30)
    v.wl = Text(v, 13, C.soft, false, "RIGHT")
    v.wl:SetPoint("TOPRIGHT", -PAD, -44)

    v.bigWin = Tile(v, "Biggest win")
    v.bigWin:SetPoint("TOPLEFT", PAD, -74)
    v.bigLoss = Tile(v, "Biggest loss")
    v.bigLoss:SetPoint("TOPLEFT", PAD + 118, -74)
    v.longest = Tile(v, "Longest duel")
    v.longest:SetPoint("TOPLEFT", PAD + 236, -74)

    Label(v, "By opponent"):SetPoint("TOPLEFT", PAD, -140)
    v.rows = {}
    for i = 1, OPP_ROWS do
        local r = CreateFrame("Frame", nil, v)
        r:SetSize(IW, 26)
        r:SetPoint("TOPLEFT", PAD, -156 - (i - 1) * 26)
        r.bg = r:CreateTexture(nil, "BACKGROUND")
        r.bg:SetAllPoints()
        r.bg:SetColorTexture(unpack(i % 2 == 0 and C.row or C.field))
        r.name = Text(r, 12, C.text)
        r.name:SetPoint("LEFT", 10, 0)
        r.wl = Text(r, 12, C.soft, false, "CENTER")
        r.wl:SetPoint("CENTER")
        r.net = Text(r, 12, C.green, false, "RIGHT")
        r.net:SetPoint("RIGHT", -10, 0)
        v.rows[i] = r
    end
    v.empty = Text(v, 12, C.muted, false, "CENTER")
    v.empty:SetPoint("TOP", 0, -190)
    v.empty:SetText("No duels yet. Go challenge someone!")
    return v
end

function UI.RefreshStats()
    local v = UI.views.stats
    local st = ns.ComputeStats()
    v.net:SetText(SignedGold(st.net))
    SetColor(v.net, st.net >= 0 and C.green or C.red)
    local total = st.w + st.l
    local pct = total > 0 and math.floor(st.w / total * 100 + 0.5) or 0
    v.wl:SetText(("|cff7fd08a%dW|r / |cffe88a8a%dL|r / %d%%"):format(st.w, st.l, pct))
    v.bigWin.value:SetText("|cff7fd08a" .. ns.Gold(st.bigWin) .. "|r")
    v.bigLoss.value:SetText("|cffe88a8a" .. ns.Gold(st.bigLoss) .. "|r")
    v.longest.value:SetText(st.longest .. " rolls")

    v.empty:SetShown(#st.opps == 0)
    for i = 1, OPP_ROWS do
        local r = v.rows[i]
        local o = st.opps[i]
        r:SetShown(o ~= nil)
        if o then
            r.name:SetText(o.name)
            r.wl:SetText(("%dW / %dL"):format(o.w, o.l))
            r.net:SetText(SignedGold(o.net))
            SetColor(r.net, o.net >= 0 and C.green or C.red)
        end
    end
end

------------------------------------------------------------------------
-- Debts view
------------------------------------------------------------------------
local DEBT_ROWS = 10

local function BuildDebts(parent)
    local v = CreateFrame("Frame", nil, parent)
    v:SetAllPoints()
    Label(v, "Unpaid"):SetPoint("TOPLEFT", PAD, -14)

    v.rows = {}
    for i = 1, DEBT_ROWS do
        local r = Panel(v)
        r:SetSize(IW, 34)
        r:SetPoint("TOPLEFT", PAD, -30 - (i - 1) * 38)
        r.text = Text(r, 12, C.soft)
        r.text:SetPoint("LEFT", 10, 0)
        r.text:SetWidth(200)
        r.text:SetWordWrap(false)
        r.b2 = Button(r, 60, 24, "Paid", "gray", function() ns.MarkPaid(r.debt) end, 11)
        r.b2:SetPoint("RIGHT", -6, 0)
        r.b1 = Button(r, 60, 24, "Nudge", "gray", function()
            local debt = r.debt
            if not debt then return end
            if debt.iWon then ns.NudgeDebt(debt) else ns.OpenTrade(debt.opp, debt.amount) end
        end, 11)
        r.b1:SetPoint("RIGHT", r.b2, "LEFT", -6, 0)
        v.rows[i] = r
    end

    v.empty = Text(v, 12, C.muted, false, "CENTER")
    v.empty:SetPoint("TOP", 0, -60)
    v.empty:SetText("No unpaid death rolls. Clean slate.")

    v.hint = Text(v, 10, C.muted, false, "CENTER")
    v.hint:SetPoint("BOTTOM", 0, 14)
    v.hint:SetWidth(IW)
    v.hint:SetText("Trades with the right amount are marked paid automatically.")
    return v
end

function UI.RefreshDebts()
    local v = UI.views.debts
    local list = ns.UnpaidDebts()
    v.empty:SetShown(#list == 0)
    for i = 1, DEBT_ROWS do
        local r = v.rows[i]
        local debt = list[i]
        r.debt = debt
        r:SetShown(debt ~= nil)
        if debt then
            local opp = ns.Short(debt.opp)
            if debt.iWon then
                r.text:SetText(("%s owes you |cfff2c94c%s|r"):format(opp, ns.Gold(debt.amount)))
                r.b1:SetLabel("Nudge")
            else
                r.text:SetText(("You owe %s |cffe88a8a%s|r"):format(opp, ns.Gold(debt.amount)))
                r.b1:SetLabel("Trade")
            end
        end
    end
end

------------------------------------------------------------------------
-- Options view
------------------------------------------------------------------------
local function NumberField(parent, key, unit, minV, maxV)
    local e = Input(parent, 52, 26, 12)
    e:SetJustifyH("RIGHT")
    e:SetNumeric(true)
    e:SetMaxLetters(4)
    local function Save(self)
        local n = tonumber(self:GetText())
        if n then ns.db.settings[key] = math.min(maxV, math.max(minV, n)) end
        self:SetText(tostring(ns.db.settings[key]))
    end
    e:SetScript("OnEditFocusLost", Save)
    e:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
    e.Sync = function(self) self:SetText(tostring(ns.db.settings[key])) end
    local u = Text(parent, 11, C.muted)
    u:SetPoint("LEFT", e, "RIGHT", 6, 0)
    u:SetText(unit)
    UI.numbers[#UI.numbers + 1] = e
    return e
end

local function BuildOptions(parent)
    local v = CreateFrame("Frame", nil, parent)
    v:SetAllPoints()
    local y = -14

    local function Section(title)
        Label(v, title):SetPoint("TOPLEFT", PAD, y)
        y = y - 20
    end
    local function AddCheck(text, key)
        Check(v, text, key):SetPoint("TOPLEFT", PAD, y)
        y = y - 22
    end
    local function AddNumber(text, key, unit, minV, maxV)
        local l = Text(v, 12, C.soft)
        l:SetPoint("TOPLEFT", PAD, y - 5)
        l:SetText(text)
        NumberField(v, key, unit, minV, maxV):SetPoint("TOPRIGHT", -PAD - 32, y)
        y = y - 30
    end

    Section("Chat")
    AddCheck("Announce in group chat (/i, /raid, /party)", "announce")
    AddCheck("Use /say when not in a group", "saySolo")
    AddCheck("Narrator quips (repeat rolls, close calls)", "quips")
    y = y - 6
    Section("Sounds")
    AddCheck("Play sound on your turn", "soundTurn")
    AddCheck("Play sound when someone rolls 1", "soundDeath")
    y = y - 6
    Section("Timers")
    AddNumber("Challenge expires after", "challengeExpire", "sec", 10, 600)
    AddNumber("Show Nudge after", "nudgeAfter", "sec", 10, 600)
    y = y - 2
    Section("Interface")
    AddCheck("Hide window in combat", "hideInCombat")
    AddCheck("Show minimap button", "minimap")

    local sl = Text(v, 12, C.soft)
    sl:SetPoint("TOPLEFT", PAD, y - 4)
    sl:SetText("Window scale")
    v.scaleText = Text(v, 12, C.text, false, "RIGHT")
    v.scaleText:SetPoint("TOPRIGHT", -PAD, y - 4)
    local s = CreateFrame("Slider", nil, v, "BackdropTemplate")
    s:SetOrientation("HORIZONTAL")
    s:SetSize(170, 10)
    s:SetPoint("TOPLEFT", PAD + 110, y - 6)
    Skin(s, C.field, C.fieldBorder)
    s:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")
    s:SetMinMaxValues(70, 150)
    s:SetValueStep(5)
    s:SetObeyStepOnDrag(true)
    s:SetScript("OnValueChanged", function(_, val)
        v.scaleText:SetText(math.floor(val + 0.5) .. "%")
    end)
    s:SetScript("OnMouseUp", function(self)
        ns.db.settings.scale = math.floor(self:GetValue() + 0.5) / 100
        UI.ApplySettings()
    end)
    v.scale = s

    local line = v:CreateTexture(nil, "ARTWORK")
    line:SetColorTexture(unpack(C.line))
    line:SetHeight(1)
    line:SetPoint("BOTTOMLEFT", PAD, 54)
    line:SetPoint("BOTTOMRIGHT", -PAD, 54)
    local foot = Text(v, 11, C.muted)
    foot:SetPoint("BOTTOMLEFT", PAD, 24)
    foot:SetText("Type /cdroll to open the window")
    local reset = Button(v, 96, 28, "Reset stats", "ghost", function()
        StaticPopup_Show("CHICLETES_DEATHROLL_RESET")
    end)
    reset:SetPoint("BOTTOMRIGHT", -PAD, 16)
    return v
end

function UI.RefreshOptions()
    for _, cb in ipairs(UI.checks) do cb:Sync() end
    for _, e in ipairs(UI.numbers) do
        if not e:HasFocus() then e:Sync() end
    end
    local v = UI.views.options
    local pct = math.floor(ns.db.settings.scale * 100 + 0.5)
    v.scale:SetValue(pct)
    v.scaleText:SetText(pct .. "%")
end

StaticPopupDialogs["CHICLETES_DEATHROLL_RESET"] = {
    text = "Reset all Chiclete's Death Roll stats, history and debts?",
    button1 = YES,
    button2 = NO,
    OnAccept = function()
        wipe(ns.db.history)
        wipe(ns.db.debts)
        ns.Refresh()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

------------------------------------------------------------------------
-- Challenge popup (opponent side)
------------------------------------------------------------------------
local function BuildPopup()
    local p = CreateFrame("Frame", "ChicletesDeathRollChallenge", UIParent, "BackdropTemplate")
    p:SetSize(340, 262)
    Skin(p, C.bg, { 0.949, 0.788, 0.298, 1 }, true)
    p:SetFrameStrata("DIALOG")
    MakeDraggable(p, "popupPoint")
    RestorePoint(p, "popupPoint", { "TOP", UIParent, "TOP", 0, -160 })
    p:Hide()

    local header = Panel(p, C.header, C.line)
    header:SetPoint("TOPLEFT", 2, -2)
    header:SetPoint("TOPRIGHT", -2, -2)
    header:SetHeight(38)
    local icon = header:CreateTexture(nil, "ARTWORK")
    icon:SetTexture(ns.ICON)
    icon:SetSize(22, 22)
    icon:SetPoint("LEFT", 10, 0)
    local title = Text(header, 16, C.gold, true)
    title:SetPoint("LEFT", icon, "RIGHT", 8, 0)
    title:SetText("Chiclete's Death Roll")

    p.msg = Text(p, 14, C.text)
    p.msg:SetPoint("TOPLEFT", 16, -54)
    p.msg:SetWidth(308)

    local function PTile(x, label)
        local t = Panel(p)
        t:SetSize(150, 50)
        t:SetPoint("TOPLEFT", x, -82)
        local l = Text(t, 10, C.label)
        l:SetPoint("TOPLEFT", 10, -8)
        l:SetText(label)
        t.value = Text(t, 17, C.gold)
        t.value:SetPoint("BOTTOMLEFT", 10, 8)
        return t
    end
    p.wager = PTile(16, "START = WAGER")
    p.first = PTile(174, "FIRST ROLL")

    p.rec = Text(p, 11, C.muted)
    p.rec:SetPoint("TOPLEFT", 16, -142)

    p.accept = Button(p, 150, 40, "Accept", "green", function()
        ns.AcceptIncoming()
        p:Hide()
    end)
    p.accept:SetPoint("TOPLEFT", 16, -164)
    p.decline = Button(p, 150, 40, "Decline", "gray", function()
        ns.DeclineIncoming()
        p:Hide()
    end, 13)
    p.decline:SetPoint("TOPLEFT", 174, -164)

    p.bar = CreateFrame("StatusBar", nil, p)
    p.bar:SetSize(308, 4)
    p.bar:SetPoint("TOPLEFT", 16, -218)
    p.bar:SetStatusBarTexture(WHITE)
    p.bar:SetStatusBarColor(unpack(C.gold))
    local bbg = p.bar:CreateTexture(nil, "BACKGROUND")
    bbg:SetAllPoints()
    bbg:SetColorTexture(unpack(C.line))
    p.exp = Text(p, 11, C.muted)
    p.exp:SetPoint("TOPLEFT", 16, -230)
    return p
end

function UI.ShowChallenge()
    local inc = ns.incoming
    local p = UI.popup
    if not inc or not p then return end
    local from = ns.Short(inc.from)
    p.msg:SetText(("|cfff2c94c%s|r challenges you to a death roll."):format(from))
    p.wager.value:SetText(ns.Gold(inc.amount))
    p.first.value:SetText(inc.challengerFirst and from or "You")
    local w, l = ns.RecordVs(inc.from)
    p.rec:SetText(("Your record vs %s: %dW / %dL"):format(from, w, l))
    p:Show()
    UI.TickPopup()
end

function UI.TickPopup()
    local p = UI.popup
    local inc = ns.incoming
    if not p then return end
    if not inc then
        p:Hide()
        return
    end
    local left = math.max(0, inc.expires - time())
    p.bar:SetMinMaxValues(0, inc.total or 60)
    p.bar:SetValue(left)
    p.exp:SetText(("Expires in %ds"):format(left))
end

------------------------------------------------------------------------
-- Main window
------------------------------------------------------------------------
local TAB_NAMES = { "Duel", "Stats", "Debts", "Options" }

function UI.Build()
    if UI.frame then return end
    UI.checks, UI.numbers = {}, {}
    UI.firstMe = ns.db.lastSetup.firstMe ~= false

    local f = CreateFrame("Frame", "ChicletesDeathRollFrame", UIParent, "BackdropTemplate")
    f:SetSize(W, 552)
    Skin(f, C.bg, C.border, true)
    f:SetFrameStrata("HIGH")
    MakeDraggable(f, "point")
    RestorePoint(f, "point", { "CENTER", UIParent, "CENTER", 0, 60 })
    f:Hide()
    f:SetScript("OnShow", function() UI.Refresh() end)
    tinsert(UISpecialFrames, f:GetName())
    UI.frame = f

    local header = Panel(f, C.header, C.line)
    header:SetPoint("TOPLEFT", 2, -2)
    header:SetPoint("TOPRIGHT", -2, -2)
    header:SetHeight(42)
    local icon = header:CreateTexture(nil, "ARTWORK")
    icon:SetTexture(ns.ICON)
    icon:SetSize(24, 24)
    icon:SetPoint("LEFT", 10, 0)
    local title = Text(header, 17, C.gold, true)
    title:SetPoint("LEFT", icon, "RIGHT", 8, 0)
    title:SetText("Chiclete's Death Roll")
    local close = Button(header, 26, 26, "X", "close", function() f:Hide() end)
    close:SetPoint("RIGHT", -8, 0)

    UI.tabs = {}
    for i, name in ipairs(TAB_NAMES) do
        local b = Button(f, 94, 32, name, "tab", function() UI.SelectTab(i) end)
        b:SetPoint("TOPLEFT", 2 + (i - 1) * 94, -44)
        b.underline = b:CreateTexture(nil, "OVERLAY")
        b.underline:SetColorTexture(unpack(C.gold))
        b.underline:SetPoint("BOTTOMLEFT")
        b.underline:SetPoint("BOTTOMRIGHT")
        b.underline:SetHeight(2)
        UI.tabs[i] = b
    end
    local sep = f:CreateTexture(nil, "ARTWORK")
    sep:SetColorTexture(unpack(C.line))
    sep:SetHeight(1)
    sep:SetPoint("TOPLEFT", 2, -76)
    sep:SetPoint("TOPRIGHT", -2, -76)

    local content = CreateFrame("Frame", nil, f)
    content:SetPoint("TOPLEFT", 0, -78)
    content:SetPoint("BOTTOMRIGHT", 0, 0)

    UI.views = {
        setup   = BuildSetup(content),
        active  = BuildActive(content),
        result  = BuildResult(content),
        stats   = BuildStats(content),
        debts   = BuildDebts(content),
        options = BuildOptions(content),
    }
    UI.views.setup.amount:SetText(ns.Num(ns.db.lastSetup.amount or 5000))

    UI.popup = BuildPopup()
    UI.tab = 1
    UI.ApplySettings()
end

function UI.SelectTab(i)
    UI.tab = i
    UI.Refresh()
end

function UI.Show(tab)
    if not UI.frame then return end
    if tab then UI.tab = tab end
    if UI.hiddenForCombat then
        UI.restoreAfterCombat = true
    else
        UI.frame:Show()
    end
    UI.Refresh()
end

function UI.Toggle()
    if not UI.frame then return end
    if UI.frame:IsShown() then UI.frame:Hide() else UI.Show() end
end

function UI.ApplySettings()
    if not UI.frame then return end
    UI.frame:SetScale(ns.db.settings.scale or 1)
    if ns.Minimap and ns.Minimap.Apply then ns.Minimap.Apply() end
    UI.Refresh()
end

function UI.CombatHide(entering)
    if not UI.frame then return end
    if entering then
        if ns.db.settings.hideInCombat and UI.frame:IsShown() then
            UI.hiddenForCombat = true
            UI.restoreAfterCombat = true
            UI.frame:Hide()
        end
    else
        if UI.hiddenForCombat then
            UI.hiddenForCombat = false
            if UI.restoreAfterCombat then UI.frame:Show() end
            UI.restoreAfterCombat = false
        end
    end
end

local function DuelView()
    local d = ns.duel
    if not d then return "setup" end
    if d.state == "done" then return "result" end
    return "active"
end

function UI.Refresh()
    if not UI.frame then return end

    local unpaid = #ns.UnpaidDebts()
    UI.tabs[3]:SetLabel(unpaid > 0 and ("Debts (" .. unpaid .. ")") or "Debts")
    for i, b in ipairs(UI.tabs) do
        b:SetStyle(i == UI.tab and "tabOn" or "tab")
        b.underline:SetShown(i == UI.tab)
    end

    local want
    if UI.tab == 1 then want = DuelView()
    elseif UI.tab == 2 then want = "stats"
    elseif UI.tab == 3 then want = "debts"
    else want = "options" end
    for name, view in pairs(UI.views) do view:SetShown(name == want) end

    if not UI.frame:IsShown() then
        UI.TickPopup()
        return
    end
    if want == "setup" then UI.RefreshSetup()
    elseif want == "active" then UI.RefreshActive()
    elseif want == "result" then UI.RefreshResult()
    elseif want == "stats" then UI.RefreshStats()
    elseif want == "debts" then UI.RefreshDebts()
    else UI.RefreshOptions() end
    UI.TickPopup()
end

function UI.Tick()
    UI.TickPopup()
    if UI.frame and UI.frame:IsShown() and UI.tab == 1 and ns.duel and ns.duel.state ~= "done" then
        UI.RefreshActive()
    end
end
