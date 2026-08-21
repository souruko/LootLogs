-- One item row, shared by the loot popup and (from M3) the loot browser.
--
-- Turbine cannot measure a label and does not clip an oversized one, so every text column is
-- truncated with _G.Truncate against _G.GlyphWidth. Icons deliberately do not scale with the
-- Font Size setting: Turbine clips a .tga to its control rather than resizing it, so a scaled
-- icon box would crop the art.
--
-- Rows are built once and re-driven through SetLoot, because a popup that rebuilds its
-- controls on every chest leaks them -- Turbine has no destructor, only reparenting to nil.

-- Item art is 36px, which is the size the client's own item images ARE. A slot smaller than its
-- picture crops it: Turbine clips art to its control instead of resizing it, which is the same
-- reason this does not scale with the Font Size setting either. The row height does scale, and is
-- floored so the icon always fits.
_G.LootSlotSize = 36

local PAD, ROW_H, ICON, RULE_W, GAP, META_W, CHANCE_W, STAR

local function Metrics()
    PAD    = _G.Scaled(8)
    GAP    = _G.Scaled(8)
    -- HOW LIKELY WHAT JUST DROPPED WAS. The browser's own figure, in the browser's own width:
    -- "70%" and "0.76%" both have to fit, and a rare hit only reads as rare if the number is
    -- there while you are looking at the thing.
    CHANCE_W = _G.Scaled(54)
    -- The looter's column. Everything it does not take goes to the NAME, and the name is what
    -- gets read -- "Blighted Shoulder-guards of Shadows" is 35 characters and used to be cut to
    -- about 20. Sized for a long character name and nothing more; the level in front of it is
    -- three digits, and the rest is the item's.
    META_W = _G.Scaled(88)
    RULE_W = 2
    ICON   = _G.LootSlotSize
    STAR   = 12
    ROW_H  = math.max(_G.Scaled(38), ICON + 6)
end

_G.RegisterMetrics(Metrics)

_G.LootRowHeight = function() return ROW_H end

-- Quality is mapped onto EXISTING theme roles rather than new ones, so every theme keeps its
-- own palette instead of importing LOTRO's item colours (which clash badly in misty).
-- An absent quality is not an error: the drops data marks it optional, and unknown falls
-- through to plain text rather than inventing a rarity.
local function QualityColor(quality)

    if quality == "incomparable" then return _G.Theme.CHIP_FAV_TEXT
    elseif quality == "rare"     then return _G.Theme.CHIP_USED_TEXT
    elseif quality == "uncommon" then return _G.Theme.TEXT
    elseif quality == "common"   then return _G.Theme.DIM2
    else                              return _G.Theme.TEXT
    end

end

_G.LootQualityColor = QualityColor

-- ================================================================================================
-- Item icon
-- ================================================================================================
-- Drawn as an ItemInfoControl -- the client's own item slot -- and NOT as either of the two
-- things it has been before.
--
-- Not a QUICKSLOT: a quickslot paints the live stack count from your bags over the art, and in a
-- listing about the world that number is meaningless at best and misleading at worst. It says how
-- many YOU are carrying, next to a drop chance that has nothing to do with you. An ItemInfoControl
-- has its own quantity, and SetQuantity(1) draws none -- which is the whole reason it can be used
-- where a quickslot could not, and it leaves the row's own stack label (SetIcon) the only count on
-- the slot. SetAllowDrop(false) for the same reason in the other direction: a catalogue is not a
-- bag, and nothing may be dropped into it.
--
-- Not LAYERED IMAGES either, which is what replaced the quickslot and what this replaces. Composing
-- an icon by hand means owning the layer order (background, then the OPAQUE quality backing, then
-- the art LAST -- get it wrong and you draw an olive green tile where a pair of boots should be)
-- and the blend mode, forever, for a picture the client already knows how to draw. Handing the
-- ItemInfo over draws the same icon in one control instead of four, and brings back the tooltip
-- that layering had cost -- the row's NAME is an item link and carries one (_G.LootDrops.ItemLink),
-- but the art is the thing the pointer lands on first.
--
-- A tooltip means the control TAKES THE MOUSE, and a mouse-visible child stops its row from seeing
-- the pointer. Where the row has a hover of its own, the icon has to re-drive it exactly as the
-- name label does -- see _G.LootBrowser:MakeItemRow.
--
-- The way in is Shortcut:GetItem():GetItemInfo(), which turns an item id into the client's record
-- without any slot being involved. That walk is _G.LootDrops.ClientInfo's -- the reference snippet
-- for this does it with a hidden 1x1 quickslot, which is the same three steps and one control more.

-- The three image ids the client composes an icon from, back to front:
--
--     background   the slot backing
--     quality      the rarity backing -- OPAQUE, so it goes UNDER the art, not over it
--     icon         the item art itself, and therefore LAST
--
-- Nothing draws from these any more -- the ItemInfoControl above does its own composing. They are
-- kept for `/lootlogs icon` (Utils/Commands.lua), which prints them to say whether an id resolves
-- to art at all, and that is now its only caller.
local function ImageIds(id)

    -- The shortcut-to-ItemInfo walk is _G.LootDrops.ClientInfo's, and lives there because the
    -- SORT needs the same record for the item's category. Two copies of it would drift, and the
    -- one thing they must agree on is what an unresolvable id means: nil, and a fallback.
    local info = _G.LootDrops.ClientInfo(id)
    if info == nil then return nil end

    local function Try(getter)
        local ok, value = pcall(function() return info[getter](info) end)
        if ok and value ~= nil and value ~= 0 then return value end
        return nil
    end

    -- no art id, no icon: the other two layers alone would draw an empty frame
    local icon = Try("GetIconImageID")
    if icon == nil then return nil end

    return {
        icon       = icon,
        background = Try("GetBackgroundImageID"),
        quality    = Try("GetQualityImageID"),
    }

end

_G.LootItemImages = ImageIds

-- Points an existing slot at a catalogued id, or empties it where the id is nil or resolves to
-- nothing. Returns whether it took: SetItemInfo(nil) is not certain to be legal, and a slot that
-- would not empty must not be left showing the last item -- see _G.LootRow:SetIcon.
--
-- An unresolvable id is COMMON and is not an error. A drop the catalogue has no id for, and an id
-- the client cannot answer for yet because the item table is not loaded, both land here and both
-- draw the empty slot: a frame where the art will be, rather than a hole in the row.
local function ShowItem(control, id)

    local info = id ~= nil and _G.LootDrops.ClientInfo(id) or nil

    return (pcall(function()
        control:SetItemInfo(info)
        -- ONE, ALWAYS. This is the number a quickslot would have taken from your bags, and drawing
        -- it is the thing that kept a quickslot out of these rows. The stack count these rows DO
        -- show is the catalogue's own, drawn as a label over the slot by SetIcon.
        control:SetQuantity(1)
    end))

end

_G.LootShowItem = ShowItem

-- Builds an item slot into `parent` showing `id`, or nil where the client cannot make one at all
-- (out of the game, in the test harness, there is no Turbine.UI.Lotro to build with) -- so callers
-- still guard, even though an unresolvable id now draws an empty slot rather than nothing.
--
-- Mouse-VISIBLE, unlike the picture this replaced: the slot's tooltip is half the point of it. A
-- row with a hover of its own has to re-drive that hover from the icon, or it goes dark under the
-- pointer.
function _G.MakeItemIcon(parent, id, size)

    local built, control = pcall(function() return Turbine.UI.Lotro.ItemInfoControl() end)
    if not built or control == nil then return nil end

    control:SetParent(parent)
    control:SetSize(size, size)
    control:SetAllowDrop(false)

    ShowItem(control, id)

    return control

end

_G.LootRow = class(Turbine.UI.Control)

function _G.LootRow:Constructor(parent)

    Turbine.UI.Control.Constructor(self)

    self:SetParent(parent)
    self:SetHeight(ROW_H)
    self:SetMouseVisible(true)

    -- left rule: accent for your own loot, frame for everyone else's
    self.rule = Turbine.UI.Control()
    self.rule:SetParent(self)
    self.rule:SetPosition(0, 0)
    self.rule:SetSize(RULE_W, ROW_H)
    self.rule:SetMouseVisible(false)

    -- The icon lives in here, and the host stays put so the layout never has to move. Mouse-visible,
    -- both of them: the slot's tooltip is why it is a slot, and a mouse-invisible host would shadow
    -- it. This row has no hover of its own to lose, so nothing has to be re-driven -- the browser's
    -- row does, and does (UI/Window/LootBrowser.lua).
    self.iconHost = Turbine.UI.Control()
    self.iconHost:SetParent(self)
    self.iconHost:SetSize(ICON, ICON)
    self.iconHost:SetPosition(RULE_W + GAP, math.floor((ROW_H - ICON) / 2))
    self.iconHost:SetMouseVisible(true)

    -- Built ONCE and re-pointed per item, not rebuilt: the popup pools its rows and re-drives them
    -- through SetLoot, so an icon made per chest would pile up controls for the session (Turbine
    -- has no destructor). It starts empty and SetIcon fills it.
    self.icon = _G.MakeItemIcon(self.iconHost, nil, ICON)

    -- THE STACK RIDES ON THE SLOT, the way the client draws it in a bag -- and it is the item's own
    -- art it belongs to, not the line of text beside it. Pooled like the slot, and added AFTER it
    -- so it draws on top: Turbine draws children in the order they were added.
    self.stack = Turbine.UI.Label()
    self.stack:SetParent(self.iconHost)
    self.stack:SetMultiline(false)
    self.stack:SetSize(ICON - 2, _G.Scaled(12))
    self.stack:SetPosition(0, ICON - _G.Scaled(12))
    self.stack:SetFont(_G.Font(9))
    self.stack:SetFontStyle(_G.Theme.FONT_STYLE)
    self.stack:SetForeColor(_G.Theme.TEXT)
    self.stack:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleRight)
    self.stack:SetMouseVisible(false)
    self.stack:SetVisible(false)

    -- Wishlist marker. Art, not a glyph: Ressources/ICONS.md records that Turbine's font
    -- cannot be relied on to draw U+2605, which is why star_on.tga exists at all.
    self.star = Turbine.UI.Control()
    self.star:SetParent(self)
    self.star:SetSize(STAR, STAR)
    self.star:SetBackground("LootLogs/Ressources/star_on.tga")
    self.star:SetBlendMode(Turbine.UI.BlendMode.Overlay)
    self.star:SetMouseVisible(false)
    self.star:SetVisible(false)

    self.nameLabel = Turbine.UI.Label()
    self.nameLabel:SetParent(self)
    self.nameLabel:SetMultiline(false)
    self.nameLabel:SetHeight(ROW_H)
    self.nameLabel:SetFont(_G.Font(12))
    self.nameLabel:SetFontStyle(_G.Theme.FONT_STYLE)
    self.nameLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)

    -- The name is an ITEM LINK, so this label parses markup and takes the mouse. Both are
    -- required: without markup the <Examine> tag prints as text, and without the mouse the
    -- click never reaches the link. Every other label on the row stays mouse-invisible so the
    -- row keeps its own hover.
    --
    -- Markup on means a "<" in the text would be swallowed as a tag. Item names do not contain
    -- one, and the text is built here rather than echoed from chat, so there is nothing to
    -- escape -- but that is why it is enabled on THIS label and not on the whole row.
    self.nameLabel:SetMarkupEnabled(true)
    self.nameLabel:SetMouseVisible(true)

    self.metaLabel = Turbine.UI.Label()
    self.metaLabel:SetParent(self)
    self.metaLabel:SetMultiline(false)
    self.metaLabel:SetHeight(ROW_H)
    self.metaLabel:SetFont(_G.Font(10))
    self.metaLabel:SetFontStyle(_G.Theme.FONT_STYLE)
    self.metaLabel:SetForeColor(_G.Theme.DIM2)
    self.metaLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleRight)
    self.metaLabel:SetMouseVisible(false)

    -- The drop chance, in the item's own size rather than the looter's: it is about the thing
    -- that dropped, not about the line it arrived on.
    self.chanceLabel = Turbine.UI.Label()
    self.chanceLabel:SetParent(self)
    self.chanceLabel:SetMultiline(false)
    self.chanceLabel:SetHeight(ROW_H)
    self.chanceLabel:SetFont(_G.Font(12))
    self.chanceLabel:SetFontStyle(_G.Theme.FONT_STYLE)
    self.chanceLabel:SetForeColor(_G.Theme.TEXT)
    self.chanceLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleRight)
    self.chanceLabel:SetMouseVisible(false)

end

-- Where the labels go. Depends on whether the star is showing, so it is recomputed both when
-- the row resizes and when its contents change -- the two are not independent, and doing them
-- in the wrong order is what leaves a name cut to fit a column it no longer occupies.
function _G.LootRow:LayoutLabels()

    local width  = self:GetWidth()
    local height = self:GetHeight()
    local nameX  = RULE_W + GAP + ICON + GAP

    self.rule:SetHeight(height)

    -- the star sits between icon and name and takes its space out of the name column, so a
    -- wishlisted row never overruns an unwishlisted one
    self.star:SetPosition(nameX, math.floor((height - STAR) / 2))
    if self.star:IsVisible() then
        nameX = nameX + STAR + math.floor(GAP / 2)
    end

    -- The chance comes off the right FIRST, so the looter column keeps its width and only the
    -- name gives any up -- the name is the one thing here that can be shortened without losing
    -- a fact, because RefreshText re-cuts it against whatever it is left with.
    local chanceX = math.max(0, width - CHANCE_W - PAD)
    local metaX   = math.max(0, chanceX - META_W)

    self.nameLabel:SetPosition(nameX, 0)
    self.nameLabel:SetHeight(height)
    self.nameLabel:SetWidth(math.max(0, metaX - nameX))

    self.metaLabel:SetPosition(metaX, 0)
    self.metaLabel:SetHeight(height)
    self.metaLabel:SetWidth(META_W)

    self.chanceLabel:SetPosition(chanceX, 0)
    self.chanceLabel:SetHeight(height)
    self.chanceLabel:SetWidth(CHANCE_W)

end

-- Text has to be re-cut whenever the row's width changes, because Turbine cannot measure a
-- label: the truncation is computed from the width at the moment it is applied. A row that
-- is filled before its first layout would otherwise measure against a near-zero width and
-- keep the stub it produced, however wide the row later became.
function _G.LootRow:RefreshText()

    local item = self.item
    if item == nil then return end

    self:LayoutLabels()

    -- The count is drawn on the slot (SetIcon), not in front of the name: it belongs to the
    -- picture of the thing, and a long name used to lose its tail paying for it. The star is a
    -- separate control and takes its own space.
    -- RowText, not the raw name: the two shapes of drops row disagree about `label` -- one
    -- renames the item with it, the other describes it -- and only it knows which is in hand.
    local shown = _G.LootDrops.RowText(self.drop)
    if self.drop == nil then shown = item.base end

    -- TRUNCATE FIRST, THEN LINK. _G.Truncate counts glyphs, and the link's tag is markup the
    -- label never draws -- measuring the wrapped string would cut the name to nothing. The two
    -- brackets ARE drawn, so their width comes off the budget.
    local glyph = _G.GlyphWidth(12)
    local text  = _G.Truncate(
        shown,
        self.nameLabel:GetWidth() - glyph * 2,
        glyph)

    self.nameLabel:SetText(_G.LootDrops.ItemLink(self.drop, text))

    local meta = item.player or ""
    if item.level then
        meta = tostring(item.level) .. _G.Sep .. meta
    end
    self.metaLabel:SetText(_G.Truncate(meta, META_W, _G.GlyphWidth(10)))

end

-- The item's own art where its id resolves to some, and the empty slot where it does not -- an
-- uncatalogued id is common and is not an error.
--
-- RE-POINTED, not rebuilt, because the slot is not made of the item: the same control shows the
-- next one. Rebuilding is the fallback for the one case that would be a bug -- a slot that will
-- not empty would leave THIS row showing the PREVIOUS row's item, and rows are pooled, so that is
-- the loot of a chest ago under somebody else's name.
function _G.LootRow:SetIcon(drop)

    local id = drop and drop.id

    if self.icon == nil or not _G.LootShowItem(self.icon, id) then

        if self.icon ~= nil then
            self.icon:SetParent(nil)
            self.icon = nil
        end

        self.icon = _G.MakeItemIcon(self.iconHost, id, ICON)

        -- The rebuilt slot went in AFTER the stack label, so it would cover it. Re-adding the
        -- label puts it back on top -- Turbine draws children in the order they were added.
        if self.icon ~= nil and self.stack ~= nil then
            self.stack:SetParent(nil)
            self.stack:SetParent(self.iconHost)
        end

    end

    local quantity = self.item ~= nil and (self.item.quantity or 1) or 1

    self.stack:SetText(quantity > 1 and ("\195\151" .. quantity) or "")  -- multiplication sign
    self.stack:SetVisible(quantity > 1)

end

-- item:       { base, level, quantity, player, isSelf }
-- drop:       the _G.Drops row, or nil for an item not in the catalogue
-- eventIndex: which chest, needed to ask whether the item's GROUP is wishlisted
function _G.LootRow:SetLoot(item, drop, eventIndex)

    self.item       = item
    self.drop       = drop
    self.eventIndex = eventIndex

    -- The same test the popup sorts on, and the same one that decides whether the popup opens
    -- at all -- including the group, so a starred "Tracery" stars every tracery row. Asking it
    -- three different ways is how a row ends up unstarred in a window it was the reason for.
    local wished = _G.LootDrops.IsWished(eventIndex, item.base)

    -- set before RefreshText, because the star's presence decides where the name starts
    self.star:SetVisible(wished)

    -- THREE CASES, TESTED IN THIS ORDER, and the middle one is the whole point: a drop you had
    -- starred that went to somebody else used to take the same blue ground as your own loot, so
    -- the best and the worst news a chest can give looked identical.
    --
    -- The two chip pairs are one cool and one warm in every theme by design (UI/Theme.lua), so
    -- "mine" and "theirs, and I wanted it" can never be read as the same event -- including in
    -- misty, where they are tints rather than fills.
    if item.isSelf then
        self:SetBackColor(_G.Theme.CHIP_FAV_BG)
        self.rule:SetBackColor(_G.Theme.ACCENT)
        self.nameLabel:SetForeColor(_G.Theme.CHIP_FAV_TEXT)
        self.metaLabel:SetForeColor(_G.Theme.ACCENT)
    elseif wished then
        self:SetBackColor(_G.Theme.CHIP_USED_BG)
        self.rule:SetBackColor(_G.Theme.CHIP_USED_FRAME)
        self.nameLabel:SetForeColor(_G.Theme.CHIP_USED_TEXT)
        self.metaLabel:SetForeColor(_G.Theme.CHIP_USED_TEXT)
    else
        self:SetBackColor(_G.Theme.BG)
        self.rule:SetBackColor(_G.Theme.FRAME)
        self.nameLabel:SetForeColor(QualityColor(drop and drop.quality))
        self.metaLabel:SetForeColor(_G.Theme.DIM2)
    end

    -- THE BROWSER'S NUMBER, not a second opinion: one helper answers for both shapes of chest,
    -- so a rate seen here and looked up there cannot disagree. Asked by NAME rather than read off
    -- the row, because a loot line has no class on it and a collapsed group ("Tracery") has no
    -- row of its own and answers for its members.
    local chance = _G.LootDrops.ChanceAt(eventIndex, item.base)
    local shown  = _G.LootDrops.FormatChance(chance)

    if shown == nil then
        -- an uncatalogued drop, or one the tables give no rate for: unknown, never 0%
        self.chanceLabel:SetForeColor(_G.Theme.DASH)
        self.chanceLabel:SetText("\226\128\148")            -- em dash
    else
        -- under 2% is the band where the number is the news. It takes the warm text so it
        -- catches the eye at the same moment the item does.
        self.chanceLabel:SetForeColor(chance < 0.02 and _G.Theme.CHIP_USED_TEXT or _G.Theme.TEXT)
        self.chanceLabel:SetText(shown)
    end

    -- AND WHERE IT CAME FROM, on the same hover the browser gives it: the rolls behind the
    -- figure, built from _G.LootDrops.RollLines, so the two windows explain one number one way.
    local odds = _G.LootDrops.OddsTooltip(drop, (_G.LootDrops.RowText(drop)))
    _G.LootTooltip.Attach(self.chanceLabel, odds)
    self.chanceLabel:SetMouseVisible(odds ~= nil)

    self:SetIcon(drop)

    self:RefreshText()

end

function _G.LootRow:SizeChanged()

    if self.nameLabel == nil then return end

    -- RefreshText lays the labels out and then re-cuts against the width it just set, which is
    -- the only order that is correct whichever way round the row was sized and filled
    if self.item ~= nil then
        self:RefreshText()
    else
        self:LayoutLabels()
    end

end
