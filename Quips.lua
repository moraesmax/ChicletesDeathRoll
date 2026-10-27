-- Chiclete's Death Roll - narrator quips
-- Placeholders: {player} {n} {count} {wager} {start} {prev}
local _, ns = ...

ns.Quips = {
    streak2 = {
        "{n} twice in a row? Somebody check the dice.",
        "{player} said 'no u' and rolled {n} right back.",
        "{n} again. The dice are stuck. Try turning them off and on.",
    },
    streak3 = {
        "Three {n}s in a row. The RNG gods are clearly bored.",
        "{n}, {n}, {n}. This is either a miracle or a bug report.",
        "Third {n} in a row. Nobody is going anywhere tonight.",
    },
    streak4 = {
        "FOUR {n}s?! Is this a death roll or a copy-paste contest?",
        "Four {n}s back to back. Blizzard, please check the server.",
        "{n} for the fourth time. Someone has been bribing the dice.",
    },
    streak5 = {
        "{count} {n}s in a row. Screenshot it. Nobody will believe you.",
        "{count} straight {n}s. I'm calling the Titans to check this.",
    },
    two = {
        "{player} rolled a 2. One pip away from paying {wager}g.",
    },
    firstOne = {
        "{player} rolled 1 out of {start}. Instant death. Bold move.",
    },
    long = {
        "Roll {count} and still going. Someone bring snacks.",
    },
    bigDrop = {
        "{player} went from {prev} to {n} in one roll. Ouch.",
    },
}

local function Fill(template, vars)
    return (template:gsub("{(%w+)}", function(key)
        local value = vars[key]
        if value == nil then return "{" .. key .. "}" end
        return tostring(value)
    end))
end

-- Returns a quip for the roll just added to d.history, or nil.
function ns.PickQuip(d, entry)
    local history = d.history
    local count = #history
    local roll = entry.roll

    local streak = 1
    for i = count - 1, 1, -1 do
        if history[i].roll == roll then streak = streak + 1 else break end
    end

    local vars = {
        player = entry.who == "me" and ns.me or ns.Short(d.opp),
        n = ns.Num(roll),
        count = streak,
        wager = ns.Num(d.amount),
        start = ns.Num(d.amount),
        prev = ns.Num(entry.max),
    }

    local q = ns.Quips
    local list
    if streak >= 5 then list = q.streak5
    elseif streak == 4 then list = q.streak4
    elseif streak == 3 then list = q.streak3
    elseif streak == 2 then list = q.streak2
    elseif roll == 1 and count == 1 then list = q.firstOne
    elseif roll == 2 then list = q.two
    elseif entry.max >= 1000 and roll > 1 and roll <= 10 then list = q.bigDrop
    elseif count == 15 then
        vars.count = count
        list = q.long
    end

    if list and #list > 0 then
        return Fill(list[math.random(#list)], vars)
    end
end
