-- Chiclete's Death Roll - core logic
local ADDON, ns = ...

ns.PREFIX   = "CDROLL"
ns.MAX_ROLL = 1000000          -- highest number WoW's /roll accepts
ns.ICON     = "Interface\\AddOns\\ChicletesDeathRoll\\ChicleteIcon"
ns.TAG      = "[Death Roll] "

local DEFAULTS = {
    settings = {
        announce = true,
        saySolo = false,
        quips = true,
        soundTurn = true,
        soundDeath = true,
        challengeExpire = 60,   -- seconds
        nudgeAfter = 60,        -- seconds
        hideInCombat = true,
        minimap = true,
        scale = 1.0,
    },
    history = {},
    debts = {},
    lastSetup = { amount = 5000, firstMe = true },
    minimapAngle = 215,
    nextId = 1,
}

------------------------------------------------------------------------
-- Helpers
------------------------------------------------------------------------
local function IsSecret(v)
    return issecretvalue ~= nil and issecretvalue(v)
end
ns.IsSecret = IsSecret

local function CopyDefaults(src, dst)
    for k, v in pairs(src) do
        if type(v) == "table" then
            if type(dst[k]) ~= "table" then dst[k] = {} end
            CopyDefaults(v, dst[k])
        elseif dst[k] == nil then
            dst[k] = v
        end
    end
end

function ns.Short(name)
    if not name then return nil end
    return name:match("^([^%-]+)") or name
end

function ns.Key(name)
    local s = ns.Short(name)
    return s and s:lower() or nil
end

function ns.Same(a, b)
    return a ~= nil and b ~= nil and ns.Key(a) == ns.Key(b)
end

function ns.Num(n)
    if BreakUpLargeNumbers then return BreakUpLargeNumbers(n) end
    return tostring(n)
end

function ns.Gold(n)
    return ns.Num(n) .. "g"
end

function ns.Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cfff2c94cChiclete's Death Roll:|r " .. msg)
end

function ns.Refresh()
    if ns.UI and ns.UI.Refresh then ns.UI.Refresh() end
end

local function Play(kit)
    if kit then PlaySound(kit, "Master") end
end

-- Your turn / incoming challenge: coin confirm. Someone rolled 1: Trading Post celebration.
function ns.PlayTurnSound()
    if ns.db.settings.soundTurn and SOUNDKIT then Play(SOUNDKIT.IG_BACKPACK_COIN_OK) end
end

function ns.PlayDeathSound()
    if ns.db.settings.soundDeath and SOUNDKIT then Play(SOUNDKIT.TRADING_POST_UI_PURCHASE_CELEBRATION) end
end

-- "5000", "5,000", "5.000", "5k", "2.5k" -> number
function ns.ParseAmount(text)
    if not text then return nil end
    local s = text:lower():gsub("[,%s]", "")
    local num, k = s:match("^(%d+%.?%d*)(k?)$")
    if not num then return nil end
    if k == "k" then
        return math.floor(tonumber(num) * 1000 + 0.5)
    end
    num = num:gsub("%.", "")
    return tonumber(num)
end

------------------------------------------------------------------------
-- Chat (announcements)
------------------------------------------------------------------------
function ns.SendChat(msg, chatType, target)
    if C_ChatInfo and C_ChatInfo.SendChatMessage then
        C_ChatInfo.SendChatMessage(msg, chatType, nil, target)
    else
        SendChatMessage(msg, chatType, nil, target)
    end
end

function ns.GroupChannel()
    if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then return "INSTANCE_CHAT" end
    if IsInRaid() then return "RAID" end
    if IsInGroup() then return "PARTY" end
    return nil
end

-- /say needs a click outside instances, so solo messages wait for the
-- next click on any of the addon's buttons.
local sayQueue = {}

function ns.Announce(text)
    local s = ns.db.settings
    if not s.announce or not text then return end
    local chan = ns.GroupChannel()
    if chan then
        ns.SendChat(ns.TAG .. text, chan)
    elseif s.saySolo then
        sayQueue[#sayQueue + 1] = ns.TAG .. text
    end
end

function ns.FlushSay()
    if #sayQueue == 0 then return end
    local queue = sayQueue
    sayQueue = {}
    for _, msg in ipairs(queue) do ns.SendChat(msg, "SAY") end
end

------------------------------------------------------------------------
-- Hidden addon messages
------------------------------------------------------------------------
local commQueue = {}

local function CommLocked()
    if C_ChatInfo and C_ChatInfo.InChatMessagingLockdown then
        local ok, locked = pcall(C_ChatInfo.InChatMessagingLockdown)
        if ok and locked then return true end
    end
    return ns.inEncounter
end

local function RawSend(payload, chan, target)
    C_ChatInfo.SendAddonMessage(ns.PREFIX, payload, chan, target)
end

local function InMyGroup(name)
    local short = ns.Short(name)
    return short and (UnitInParty(short) or UnitInRaid(short)) and true or false
end
ns.InMyGroup = InMyGroup

-- Payload: "<recipient key>|<command>|<arg1>|<arg2>..."
function ns.SendComm(cmd, target, ...)
    if not target then return end
    local parts = { ns.Key(target), cmd }
    for i = 1, select("#", ...) do parts[#parts + 1] = tostring((select(i, ...))) end
    local payload = table.concat(parts, "|")
    local chan = ns.GroupChannel()
    local useGroup = chan and InMyGroup(target)
    local c = useGroup and chan or "WHISPER"
    local t = (not useGroup) and target or nil
    if CommLocked() then
        commQueue[#commQueue + 1] = { payload, c, t }
    else
        RawSend(payload, c, t)
    end
end

local function FlushComm()
    if #commQueue == 0 or CommLocked() then return end
    local queue = commQueue
    commQueue = {}
    for _, m in ipairs(queue) do RawSend(m[1], m[2], m[3]) end
end

------------------------------------------------------------------------
-- Addon detection
------------------------------------------------------------------------
ns.addonUsers = {}   -- key -> { state = "yes"|"no"|"checking"|"unknown", t = GetTime() }

function ns.AddonStatus(name)
    local key = ns.Key(name)
    local e = key and ns.addonUsers[key]
    return e and e.state or nil
end

local function IsTargeted(name)
    if not UnitExists("target") then return false end
    local n = UnitName("target")
    if IsSecret(n) then return false end
    return ns.Same(n, name)
end

function ns.Probe(name)
    if not name or name == "" or ns.Same(name, ns.me) then return end
    local key = ns.Key(name)
    local e = ns.addonUsers[key]
    if e and e.state == "yes" then return end
    if e and e.state == "checking" and (GetTime() - e.t) < 3 then return end
    -- Only whisper people we can actually reach, to avoid "player not found" spam.
    if not (InMyGroup(name) or IsTargeted(name)) then
        ns.addonUsers[key] = { state = "unknown", t = GetTime() }
        ns.Refresh()
        return
    end
    ns.addonUsers[key] = { state = "checking", t = GetTime() }
    ns.SendComm("PING", name)
    C_Timer.After(2.5, function()
        local cur = ns.addonUsers[key]
        if cur and cur.state == "checking" then
            cur.state = "no"
            ns.Refresh()
        end
    end)
    ns.Refresh()
end

------------------------------------------------------------------------
-- Roll message parsing (works on every client language)
------------------------------------------------------------------------
local function BuildRollParser()
    local fmt = RANDOM_ROLL_RESULT or "%s rolls %d (%d-%d)"
    local order, pattern, i, seq = {}, "", 1, 0
    while i <= #fmt do
        local c = fmt:sub(i, i)
        if c == "%" then
            if fmt:sub(i + 1, i + 1) == "%" then
                pattern = pattern .. "%%"
                i = i + 2
            else
                local a, b, pos, typ = fmt:find("^%%(%d)%$([sd])", i)
                if not a then
                    a, b, typ = fmt:find("^%%([sd])", i)
                    if a then seq = seq + 1; pos = seq end
                end
                if a then
                    order[#order + 1] = tonumber(pos)
                    pattern = pattern .. (typ == "s" and "(.+)" or "(%d+)")
                    i = b + 1
                else
                    pattern = pattern .. "%%"
                    i = i + 1
                end
            end
        elseif c:find("[%^%$%(%)%.%[%]%*%+%-%?]") then
            pattern = pattern .. "%" .. c
            i = i + 1
        else
            pattern = pattern .. c
            i = i + 1
        end
    end
    ns.rollPattern = "^" .. pattern .. "$"
    ns.rollOrder = order
end

function ns.ParseRoll(msg)
    if not ns.rollPattern then BuildRollParser() end
    local caps = { msg:match(ns.rollPattern) }
    if #caps < 4 then return nil end
    local v = {}
    for k, pos in ipairs(ns.rollOrder) do v[pos] = caps[k] end
    return v[1], tonumber(v[2]), tonumber(v[3]), tonumber(v[4])
end

------------------------------------------------------------------------
-- Duels
------------------------------------------------------------------------
local function NewDuel(opp, amount, firstMe, isChallenger, oppHasAddon)
    return {
        opp = opp,
        amount = amount,
        max = amount,
        firstMe = firstMe,
        turn = firstMe and "me" or "opp",
        isChallenger = isChallenger,
        oppHasAddon = oppHasAddon,
        state = "active",
        history = {},
        started = time(),
        lastAction = time(),
    }
end

local function SetDuel(d)
    ns.duel = d
    ns.db.active = d
end

function ns.ClearDuel()
    ns.duel = nil
    ns.db.active = nil
    ns.Refresh()
end

function ns.IsBusy()
    local d = ns.duel
    return d ~= nil and (d.state == "active" or d.state == "pending")
end

local function FirstName(d)
    return d.firstMe and ns.me or ns.Short(d.opp)
end

function ns.StartChallenge(opp, amount, firstMe)
    opp = opp and strtrim(opp) or ""
    if opp == "" then return false, "Pick an opponent first." end
    if ns.Same(opp, ns.me) then return false, "You can't death roll yourself. Well, you can, but you'd lose." end
    if not amount or amount < 2 then return false, "Enter an amount of at least 2 gold." end
    amount = math.floor(amount)
    if amount > ns.MAX_ROLL then
        return false, ("WoW's /roll only goes up to %s."):format(ns.Num(ns.MAX_ROLL))
    end
    if ns.IsBusy() then return false, "Finish your current duel first." end

    local hasAddon = ns.AddonStatus(opp) == "yes"
    local d = NewDuel(opp, amount, firstMe, true, hasAddon)
    ns.db.lastSetup.amount = amount
    ns.db.lastSetup.firstMe = firstMe

    if hasAddon then
        d.state = "pending"
        d.expires = time() + ns.db.settings.challengeExpire
        SetDuel(d)
        ns.SendComm("CH", opp, amount, firstMe and "C" or "O", ns.db.settings.challengeExpire)
    else
        SetDuel(d)
    end

    ns.Announce(("%s challenges %s for %s! %s rolls first (/roll %d)."):format(
        ns.me, ns.Short(opp), ns.Gold(amount), FirstName(d), amount))
    ns.Refresh()
    return true
end

function ns.Rematch()
    local d = ns.duel
    if not d then return end
    local ok, err = ns.StartChallenge(d.opp, d.amount, not d.firstMe)
    if not ok then ns.Print(err) end
end

function ns.AcceptIncoming()
    local inc = ns.incoming
    if not inc then return end
    ns.incoming = nil
    if ns.IsBusy() then
        ns.SendComm("BUSY", inc.from)
        ns.Refresh()
        return
    end
    local firstMe = not inc.challengerFirst
    local d = NewDuel(inc.from, inc.amount, firstMe, false, true)
    SetDuel(d)
    ns.addonUsers[ns.Key(inc.from)] = { state = "yes", t = GetTime() }
    ns.SendComm("AC", inc.from)
    if firstMe then ns.PlayTurnSound() end
    if ns.UI then ns.UI.Show(1) end
    ns.Refresh()
end

function ns.DeclineIncoming()
    local inc = ns.incoming
    if not inc then return end
    ns.incoming = nil
    ns.SendComm("DE", inc.from)
    ns.Refresh()
end

function ns.DoRoll()
    local d = ns.duel
    if not d or d.state ~= "active" or d.turn ~= "me" then return end
    if d.rollPending and GetTime() - d.rollPending < 3 then return end
    d.rollPending = GetTime()
    local roll = RandomRoll or (C_RandomRoll and C_RandomRoll.RandomRoll)
    if roll then roll(1, d.max) end
    ns.Refresh()
end

function ns.Warn(msg)
    ns.Print("|cffe88a8a" .. msg .. "|r")
    ns.warnText = msg
    ns.warnUntil = GetTime() + 8
    ns.Refresh()
end

local function AddHistory(d, result, reason)
    local db = ns.db
    local id = db.nextId
    db.nextId = id + 1
    db.history[#db.history + 1] = {
        id = id, opp = d.opp, amount = d.amount, result = result,
        reason = reason, rolls = #d.history, time = time(),
    }
    if result == "win" or result == "loss" then
        db.debts[#db.debts + 1] = {
            id = id, opp = d.opp, amount = d.amount,
            iWon = (result == "win"), paid = false, time = time(),
        }
        d.debtId = id
    end
end

-- Called when someone rolls a 1. result: "win" | "loss"
function ns.Finish(result, reason)
    local d = ns.duel
    if not d or d.state == "done" then return end
    d.state = "done"
    d.result = result
    d.reason = reason
    d.rollPending = nil
    AddHistory(d, result, reason)

    if d.isChallenger or not d.oppHasAddon then
        local opp = ns.Short(d.opp)
        local winner = result == "win" and ns.me or opp
        local loser = result == "win" and opp or ns.me
        ns.Announce(("%s rolled 1! %s wins %s."):format(loser, winner, ns.Gold(d.amount)))
    end

    ns.PlayDeathSound()
    if ns.UI then ns.UI.Show(1) end
    ns.Refresh()
end

-- Ends a duel before anyone rolls a 1. There is no winner, so nothing is
-- recorded: no win, no loss, no debt, no stats.
function ns.EndDuel(byMe)
    local d = ns.duel
    if not d then return end
    if d.state == "pending" then
        if byMe then ns.SendComm("CA", d.opp) end
        ns.ClearDuel()
        return
    end
    if d.state ~= "active" then return end

    local word = #d.history == 0 and "cancelled" or "ended early"
    if byMe and d.oppHasAddon then ns.SendComm("EN", d.opp) end
    if d.isChallenger or not d.oppHasAddon then
        ns.Announce(("Death roll between %s and %s %s. No gold owed."):format(ns.me, ns.Short(d.opp), word))
    end
    if byMe then
        ns.Print(("Death roll vs %s %s. Nothing was recorded."):format(ns.Short(d.opp), word))
    else
        ns.Print(("%s %s the death roll. Nothing was recorded."):format(ns.Short(d.opp),
            #d.history == 0 and "cancelled" or "ended"))
    end
    ns.ClearDuel()
end

function ns.Nudge()
    local d = ns.duel
    if not d or d.state ~= "active" or d.turn ~= "opp" then return end
    ns.SendChat(("%sYour turn! Type /roll %d"):format(ns.TAG, d.max), "WHISPER", d.opp)
    d.nudged = time()
    ns.Refresh()
end

local function OnRoll(name, roll, lo, hi)
    local d = ns.duel
    if not d or d.state ~= "active" then return end

    local who
    if ns.Same(name, ns.me) then who = "me"
    elseif ns.Same(name, d.opp) then who = "opp"
    else return end

    if who ~= d.turn then
        if not (lo == 1 and hi == 100) then
            ns.Warn(("%s rolled out of turn, ignored."):format(ns.Short(name)))
        end
        return
    end
    if lo ~= 1 or hi ~= d.max then
        ns.Warn(("%s rolled %d-%d, expected 1-%d, ignored."):format(ns.Short(name), lo, hi, d.max))
        return
    end

    local entry = { who = who, max = d.max, roll = roll }
    d.history[#d.history + 1] = entry
    d.lastAction = time()
    d.nudged = nil
    if who == "me" then d.rollPending = nil end

    if (d.isChallenger or not d.oppHasAddon) and ns.db.settings.quips then
        local quip = ns.PickQuip(d, entry)
        if quip then ns.Announce(quip) end
    end

    if roll == 1 then
        ns.Finish(who == "me" and "loss" or "win", "roll")
        return
    end

    d.max = roll
    d.turn = (who == "me") and "opp" or "me"
    if d.turn == "me" then ns.PlayTurnSound() end
    ns.Refresh()
end

------------------------------------------------------------------------
-- Comm handling
------------------------------------------------------------------------
local function OnComm(text, sender)
    if IsSecret(text) or IsSecret(sender) then return end
    if ns.Same(sender, ns.me) then return end
    local to, cmd, a1, a2, a3 = strsplit("|", text)
    if to ~= ns.Key(ns.me) then return end

    local d = ns.duel
    local fromOpp = d and ns.Same(sender, d.opp)

    if cmd == "PING" then
        ns.SendComm("PONG", sender)
        ns.addonUsers[ns.Key(sender)] = { state = "yes", t = GetTime() }
    elseif cmd == "PONG" then
        ns.addonUsers[ns.Key(sender)] = { state = "yes", t = GetTime() }
        ns.Refresh()
    elseif cmd == "CH" then
        ns.addonUsers[ns.Key(sender)] = { state = "yes", t = GetTime() }
        if ns.IsBusy() then
            ns.SendComm("BUSY", sender)
            return
        end
        local amount = tonumber(a1)
        if not amount then return end
        ns.incoming = {
            from = sender,
            amount = amount,
            challengerFirst = (a2 == "C"),
            expires = time() + (tonumber(a3) or 60),
            total = tonumber(a3) or 60,
        }
        if ns.UI then ns.UI.ShowChallenge() end
        ns.PlayTurnSound()
    elseif cmd == "CA" then
        if ns.incoming and ns.Same(ns.incoming.from, sender) then
            ns.incoming = nil
            ns.Refresh()
        end
    elseif cmd == "AC" then
        if fromOpp and d.state == "pending" then
            d.state = "active"
            d.lastAction = time()
            d.expires = nil
            ns.Announce(("%s accepted. %s rolls first."):format(ns.Short(d.opp), FirstName(d)))
            if d.turn == "me" then ns.PlayTurnSound() end
            ns.Refresh()
        end
    elseif cmd == "DE" or cmd == "BUSY" then
        if fromOpp and d.state == "pending" then
            ns.Print(cmd == "DE" and ("%s declined your challenge."):format(ns.Short(d.opp))
                or ("%s is already in a death roll."):format(ns.Short(d.opp)))
            ns.ClearDuel()
        end
    elseif cmd == "EN" then
        if fromOpp and d.state == "active" then ns.EndDuel(false) end
    end
end

------------------------------------------------------------------------
-- Stats and debts
------------------------------------------------------------------------
function ns.ComputeStats()
    local st = { net = 0, w = 0, l = 0, bigWin = 0, bigLoss = 0, longest = 0, opps = {} }
    local byKey = {}
    for _, h in ipairs(ns.db.history) do
        if h.result == "win" or h.result == "loss" then
            local key = ns.Key(h.opp)
            local o = byKey[key]
            if not o then
                o = { name = ns.Short(h.opp), w = 0, l = 0, net = 0, n = 0 }
                byKey[key] = o
                st.opps[#st.opps + 1] = o
            end
            o.n = o.n + 1
            if h.result == "win" then
                st.w = st.w + 1; o.w = o.w + 1
                st.net = st.net + h.amount; o.net = o.net + h.amount
                if h.amount > st.bigWin then st.bigWin = h.amount end
            else
                st.l = st.l + 1; o.l = o.l + 1
                st.net = st.net - h.amount; o.net = o.net - h.amount
                if h.amount > st.bigLoss then st.bigLoss = h.amount end
            end
        end
        if (h.rolls or 0) > st.longest then st.longest = h.rolls end
    end
    table.sort(st.opps, function(a, b) return a.n > b.n end)
    return st
end

function ns.RecordVs(name)
    local w, l, net = 0, 0, 0
    for _, h in ipairs(ns.db.history) do
        if ns.Same(h.opp, name) then
            if h.result == "win" then w = w + 1; net = net + h.amount
            elseif h.result == "loss" then l = l + 1; net = net - h.amount end
        end
    end
    return w, l, net
end

function ns.UnpaidDebts()
    local list = {}
    for i = #ns.db.debts, 1, -1 do
        local debt = ns.db.debts[i]
        if not debt.paid then list[#list + 1] = debt end
    end
    return list
end

function ns.FindDebt(id)
    if not id then return nil end
    for _, debt in ipairs(ns.db.debts) do
        if debt.id == id then return debt end
    end
end

function ns.MarkPaid(debt)
    if debt then debt.paid = true; debt.paidAt = time() end
    ns.Refresh()
end

function ns.NudgeDebt(debt)
    if not debt or not debt.iWon then return end
    ns.SendChat(("%sFriendly reminder: you owe me %s from our death roll."):format(ns.TAG, ns.Gold(debt.amount)),
        "WHISPER", debt.opp)
    ns.Print(("Reminded %s about %s."):format(ns.Short(debt.opp), ns.Gold(debt.amount)))
end

function ns.OpenTrade(name, payAmount)
    local short = ns.Short(name)
    local unit
    if IsTargeted(name) then unit = "target"
    elseif InMyGroup(name) then unit = short end
    if not unit then
        ns.Print(("Target %s to open a trade."):format(short))
        return
    end
    InitiateTrade(unit)
    if payAmount then
        ns.Print(("Put %s in the trade window for %s."):format(ns.Gold(payAmount), short))
    end
end

-- Trade tracking: marks debts paid when the right gold changes hands.
local trade = {}

local function SnapshotTrade()
    trade.got = GetTargetTradeMoney and GetTargetTradeMoney() or 0
    trade.gave = GetPlayerTradeMoney and GetPlayerTradeMoney() or 0
end

local function ApplyTrade()
    if not trade.partner then return end
    local got, gave = trade.got or 0, trade.gave or 0
    for _, debt in ipairs(ns.db.debts) do
        if not debt.paid and ns.Same(debt.opp, trade.partner) then
            local copper = debt.amount * 10000
            if debt.iWon and got >= copper then
                got = got - copper
                ns.MarkPaid(debt)
                ns.Print(("%s paid you %s. Marked as paid."):format(ns.Short(debt.opp), ns.Gold(debt.amount)))
            elseif not debt.iWon and gave >= copper then
                gave = gave - copper
                ns.MarkPaid(debt)
                ns.Print(("You paid %s %s. Marked as paid."):format(ns.Short(debt.opp), ns.Gold(debt.amount)))
            end
        end
    end
    trade = {}
end

------------------------------------------------------------------------
-- Timers
------------------------------------------------------------------------
function ns.Tick()
    local d = ns.duel
    if d and d.state == "pending" and d.expires and time() > d.expires then
        ns.SendComm("CA", d.opp)
        ns.Print(("Your challenge to %s expired."):format(ns.Short(d.opp)))
        ns.ClearDuel()
    end
    if ns.incoming and time() > ns.incoming.expires then
        ns.incoming = nil
        ns.Refresh()
    end
    if ns.UI and ns.UI.Tick then ns.UI.Tick() end
end

------------------------------------------------------------------------
-- Events
------------------------------------------------------------------------
local ev = CreateFrame("Frame")
ev:RegisterEvent("ADDON_LOADED")
ev:RegisterEvent("PLAYER_LOGIN")

ev:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local name = ...
        if name ~= ADDON then return end
        ChicletesDeathRollDB = ChicletesDeathRollDB or {}
        CopyDefaults(DEFAULTS, ChicletesDeathRollDB)
        ns.db = ChicletesDeathRollDB
        -- Clean up settings left by test builds.
        ns.db.settings.turnSound, ns.db.settings.deathSound, ns.db.settings.abandonAfter = nil, nil, nil
        self:UnregisterEvent("ADDON_LOADED")

    elseif event == "PLAYER_LOGIN" then
        ns.me = UnitName("player")
        BuildRollParser()
        C_ChatInfo.RegisterAddonMessagePrefix(ns.PREFIX)

        local d = ns.db.active
        if d then
            d.rollPending = nil
            if d.state == "pending" and (not d.expires or time() > d.expires) then
                ns.db.active = nil
            elseif d.state == "active" then
                ns.duel = d
                ns.Print(("Resumed your death roll vs %s (max %s)."):format(ns.Short(d.opp), ns.Num(d.max)))
            else
                ns.duel = d
            end
        end

        if ns.UI then ns.UI.Build() end
        if ns.Minimap then ns.Minimap.Build() end

        for _, e in ipairs({
            "CHAT_MSG_SYSTEM", "CHAT_MSG_ADDON", "TRADE_SHOW", "TRADE_MONEY_CHANGED",
            "TRADE_ACCEPT_UPDATE", "UI_INFO_MESSAGE", "PLAYER_REGEN_DISABLED",
            "PLAYER_REGEN_ENABLED", "ENCOUNTER_START", "ENCOUNTER_END", "GROUP_ROSTER_UPDATE",
        }) do
            self:RegisterEvent(e)
        end
        C_Timer.NewTicker(1, ns.Tick)

    elseif event == "CHAT_MSG_SYSTEM" then
        local msg = ...
        if not msg or IsSecret(msg) then return end
        local name, roll, lo, hi = ns.ParseRoll(msg)
        if name and roll then OnRoll(name, roll, lo, hi) end

    elseif event == "CHAT_MSG_ADDON" then
        local prefix, text, _, sender = ...
        if prefix == ns.PREFIX then OnComm(text, sender) end

    elseif event == "TRADE_SHOW" then
        local partner = UnitName("NPC")
        trade = { partner = (not IsSecret(partner)) and partner or nil }
        SnapshotTrade()

    elseif event == "TRADE_MONEY_CHANGED" then
        SnapshotTrade()

    elseif event == "TRADE_ACCEPT_UPDATE" then
        SnapshotTrade()

    elseif event == "UI_INFO_MESSAGE" then
        local _, msg = ...
        if msg and not IsSecret(msg) and msg == ERR_TRADE_COMPLETE then ApplyTrade() end

    elseif event == "PLAYER_REGEN_DISABLED" then
        if ns.UI then ns.UI.CombatHide(true) end

    elseif event == "PLAYER_REGEN_ENABLED" then
        if ns.UI then ns.UI.CombatHide(false) end

    elseif event == "ENCOUNTER_START" then
        ns.inEncounter = true

    elseif event == "ENCOUNTER_END" then
        ns.inEncounter = false
        C_Timer.After(1, FlushComm)

    elseif event == "GROUP_ROSTER_UPDATE" then
        ns.Refresh()
    end
end)

------------------------------------------------------------------------
-- Slash command and addon compartment
------------------------------------------------------------------------
SLASH_CHICLETESDEATHROLL1 = "/cdroll"
SlashCmdList["CHICLETESDEATHROLL"] = function(msg)
    msg = strtrim((msg or ""):lower())
    if not ns.UI then return end
    if msg == "options" or msg == "config" then ns.UI.Show(4)
    elseif msg == "stats" then ns.UI.Show(2)
    elseif msg == "debts" then ns.UI.Show(3)
    else ns.UI.Toggle() end
end

function ChicletesDeathRoll_OnCompartmentClick()
    if ns.UI then ns.UI.Toggle() end
end
