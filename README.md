# Chiclete's Death Roll

One-click death roll duels for World of Warcraft Retail, with group announcements,
stats, debt tracking and a narrator who has opinions about your dice.

**Game version:** Retail 12.1.5 (Interface 120105)
**Dependencies:** none

---

## What is a death roll?

Two players agree on a starting number, which is also the gold wager. The first player
types `/roll 5000`, gets a number (say 2918), and the second player rolls `1-2918`.
They keep taking turns, each rolling up to the last result, until someone rolls a **1**.
That player loses and pays the wager.

This addon does the bookkeeping, so nobody has to type `/roll` numbers or argue about
whose turn it was.

---

## Features

- **One-click rolling.** The Roll button always uses the correct range for your turn.
- **Works with anyone.** If your opponent doesn't have the addon, it reads their
  `/roll` results straight from chat.
- **Challenge popup.** Opponents who do have the addon get a popup with Accept and
  Decline buttons and a countdown.
- **Roll validation.** Rolls from other players, out of turn, or with the wrong range
  are ignored, and you get a warning in the window and in chat.
- **Group announcements.** The challenge, the accept, the result and narrator quips are
  posted to /instance, /raid or /party, whichever fits your group, so everyone can watch.
- **Narrator quips.** Repeat rolls, close calls, huge drops and marathon duels get a
  comment.
- **Stats.** Net gold, wins and losses, win rate, biggest win and loss, longest duel,
  and your record against each opponent.
- **Debt tracking.** Unpaid duels are listed in both directions. Trading the right
  amount marks a debt as paid automatically.
- **Nudges.** If your opponent goes quiet, whisper them a reminder in one click.
  Remind people who owe you gold the same way.
- **Cancel or end anytime.** A duel only has a winner when someone rolls a 1. Ending it
  earlier records nothing: no win, no loss, no debt.
- **Survives reloads.** An active duel continues after `/reload` or a disconnect.
- **Any client language.** Roll messages are read in the client's own language.
- **Custom minimap button**, plus an entry in the addon compartment.
- **Hides in combat** and comes back when combat ends.

---

## Installation

### Manual
1. Download and unzip the addon.
2. Move the `ChicletesDeathRoll` folder to:
   ```
   World of Warcraft\_retail_\Interface\AddOns\
   ```
3. Start the game and make sure **Chiclete's Death Roll** is enabled under
   **AddOns** on the character select screen.

The folder must be named exactly `ChicletesDeathRoll` and contain the `.toc` file
directly inside it (not in a second nested folder).

---

## Quick start

1. Open the window with the skull **minimap button**, the **addon compartment**, or `/cdroll`.
2. Type your opponent's name or target them and press **Use target**.
3. Pick an amount with the 5k / 10k / 20k / 25k / 50k buttons, or type any amount.
   Typing `5000`, `5,000`, `5.000` or `5k` all work.
4. Choose who rolls first and press **Start Duel**.
5. When it says **YOUR TURN**, press **Roll**.
6. When someone rolls a 1, the result screen shows who won and who owes what.
   Use **Open trade** to pay up, or **Rematch** to go again (the other player rolls first).

---

## Chat commands

| Command | What it does |
|---|---|
| `/cdroll` | Open or close the window |
| `/cdroll stats` | Open the Stats tab |
| `/cdroll debts` | Open the Debts tab |
| `/cdroll options` | Open the Options tab (`/cdroll config` also works) |
Mouse controls on the minimap button: **left-click** opens the window,
**right-click** opens Options, **drag** moves the button around the minimap.

---

## How it works

### When your opponent has the addon
1. When you enter their name, the addon checks quietly whether they have it. The setup
   screen shows "Addon detected".
2. **Start Duel** sends them a challenge popup and posts the challenge in group chat.
3. When they accept, the duel starts and the acceptance is announced.
4. Only the challenger's addon posts announcements, so the group never sees the same line twice.

### When your opponent doesn't have the addon
1. **Start Duel** posts the challenge in chat, including the number they need to roll.
2. The addon reads both players' rolls from chat and keeps track of turns.
3. Your opponent just types `/roll <number>` as usual.
4. If they don't want to play, press **Cancel**. It's available until the first roll,
   records nothing and posts a short "cancelled" line in chat.

### Where announcements go

| Your situation | Channel |
|---|---|
| Instance group (LFG, LFR, battlegrounds) | /instance |
| Raid | /raid |
| Party | /party |
| Not grouped | Nothing, unless **Use /say when not in a group** is on |

All announcements are in English. When you're not grouped, WoW only allows /say from a
click, so those messages are sent the next time you click a button in the addon window.

### What the group sees
```
[Party] [Maxi]: [Death Roll] Maxi challenges Thrallbro for 5,000g! Maxi rolls first (/roll 5000).
[Party] [Maxi]: [Death Roll] Thrallbro accepted. Maxi rolls first.
Maxi rolls 2918 (1-5000)
Thrallbro rolls 347 (1-2918)
Maxi rolls 347 (1-347)
[Party] [Maxi]: [Death Roll] 347 twice in a row? Somebody check the dice.
...
Thrallbro rolls 1 (1-23)
[Party] [Maxi]: [Death Roll] Thrallbro rolled 1! Maxi wins 5,000g.
```

---

## Narrator quips

At most one quip is posted per roll. Each one is picked at random from its group.
Turn them off under **Options > Chat > Narrator quips**.

**Same number twice in a row**
- "{n} twice in a row? Somebody check the dice."
- "{player} said 'no u' and rolled {n} right back."
- "{n} again. The dice are stuck. Try turning them off and on."

**Three in a row**
- "Three {n}s in a row. The RNG gods are clearly bored."
- "{n}, {n}, {n}. This is either a miracle or a bug report."
- "Third {n} in a row. Nobody is going anywhere tonight."

**Four in a row**
- "FOUR {n}s?! Is this a death roll or a copy-paste contest?"
- "Four {n}s back to back. Blizzard, please check the server."
- "{n} for the fourth time. Someone has been bribing the dice."

**Five or more in a row**
- "{count} {n}s in a row. Screenshot it. Nobody will believe you."
- "{count} straight {n}s. I'm calling the Titans to check this."

**Other moments**
- Rolling a 2: "{player} rolled a 2. One pip away from paying {wager}g."
- Rolling 1 on the very first roll: "{player} rolled 1 out of {start}. Instant death. Bold move."
- Reaching roll 15: "Roll {count} and still going. Someone bring snacks."
- Dropping from 1,000 or more to 10 or less: "{player} went from {prev} to {n} in one roll. Ouch."

To change or add lines, edit `Quips.lua`. Placeholders: `{player}`, `{n}` (the roll),
`{count}`, `{wager}`, `{start}`, `{prev}` (the range the roll came from).

---

## Stats and debts

**Stats tab:** net gold, wins and losses with win rate, biggest win, biggest loss,
longest duel, and your record and net gold against each opponent.

**Debts tab:** every unpaid duel, newest first.
- *They owe you:* **Nudge** whispers them a friendly reminder.
- *You owe them:* **Trade** opens a trade and tells you how much gold to add.
- **Paid** marks a debt as settled by hand.

Debts are marked paid automatically when a trade with that player completes and the
gold in it covers the amount. Cancelled or ended duels never create a debt.

---

## Options

| Option | Default | Notes |
|---|---|---|
| Announce in group chat | On | Also on the setup screen |
| Use /say when not in a group | Off | Sent on your next click in the addon |
| Narrator quips | On | |
| Play sound on your turn | On | Also plays when a challenge arrives |
| Play sound when someone rolls 1 | On | |
| Challenge expires after | 60 sec | 10 to 600 |
| Show Nudge after | 60 sec | Opponent idle time before Nudge appears |
| Hide window in combat | On | Reopens after combat |
| Show minimap button | On | The addon compartment entry is always available |
| Window scale | 100% | 70% to 150% |
| Reset stats | | Clears history, stats and debts after a confirmation |

Settings, stats, debts and the active duel are saved per account in
`WTF\Account\<account>\SavedVariables\ChicletesDeathRoll.lua`.

---

## FAQ

**Does my opponent need the addon?**
No. Without it they just type `/roll` as usual. With it they get the challenge popup.

**Can the addon roll for me automatically?**
No. You click Roll on your turn. WoW expects player input for each roll, and it keeps the duel fair.

**Can it send the gold for me?**
No. Addons can't move gold on their own. Use **Open trade** and add the gold yourself.

**Is there a maximum amount?**
The addon accepts anything up to 1,000,000, the highest number WoW's `/roll` accepts.

**Someone else rolled for loot in the middle of our duel. Did it break?**
No. Only rolls from the two players, in turn and with the correct range, count.
Other rolls are ignored. Regular 1-100 rolls are ignored without a warning.

**How do I call off a duel?**
Use the button under the history. It says **Cancel** before the first roll and
**End duel** after it. Either way, nothing is recorded and no gold is owed, because a
duel only has a winner when someone rolls a 1. A short line is posted in chat so
everyone knows it's off. Either player can end it if both have the addon.

**I reloaded my UI mid-duel.**
The duel picks up where it left off, with the same number and the same turn.

**What happens during a boss fight or a Mythic+ run?**
WoW blocks hidden addon messages during encounters, so challenges and accepts sent
then wait until the encounter ends. Rolls and announcements still work.

**Does it work if my game is in another language?**
Yes. Roll messages are read in your client's language. Announcements are always in English.

---

## Troubleshooting

- **The addon doesn't show up in the AddOns list.** Check the folder path and name
  (see Installation). If the game was just patched, tick "Load out of date AddOns".
- **My roll was ignored.** The window shows why, for example "rolled 1-1000, expected 1-347".
  Press the Roll button instead of typing `/roll` by hand.
- **"Not in your group or targeted".** The addon can only check for the addon on players
  in your group or your current target. The duel still works through chat.
- **Lua errors.** Turn on error popups with `/console scriptErrors 1`, reproduce the
  problem, and include the error text when you report it.

---

## Files

| File | Contents |
|---|---|
| `ChicletesDeathRoll.toc` | Addon metadata and load order |
| `Core.lua` | Duel logic, roll parsing, chat and addon messages, stats, debts, trades |
| `UI.lua` | Main window, tabs and challenge popup |
| `Quips.lua` | Narrator lines |
| `Minimap.lua` | Minimap button |
| `ChicleteIcon.tga` | Skull icon |

---

## Changelog

### 0.1.0
- First release.
