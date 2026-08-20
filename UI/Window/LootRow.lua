-- One item row, shared by the loot popup and (from M3) the loot browser.
--
-- Turbine cannot measure a label and does not clip an oversized one, so every text column is
-- truncated with _G.Truncate against _G.GlyphWidth. Icons deliberately do not scale with the
-- Font Size setting: Turbine clips a .tga to its control rather than resizing it, so a scaled
-- icon box would crop the art.
--
-- Rows are built once and re-driven through SetLoot, because a popup that rebuilds its
-- controls on every chest leaks them -- Turbine has no destructor, only reparenting to nil.

-- Item art is 32px. Like every other icon here it does not scale with the Font Size setting --
-- Turbine clips art to its control instead of resizing it, so a scaled box would crop the
-- picture. The row height does scale, and is floored so the icon always fits.
_G.LootSlotSize = 32

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
-- Drawn as layered IMAGES, not as a quickslot.
--
-- A quickslot works and was what this used at first, but it paints the live stack count from
-- your bags over the art. In a listing about the world that number is meaningless at best and
-- misleading at worst: it says how many YOU are carrying, next to a drop chance that has nothing
-- to do with you.
--
-- What kept the quickslot around was its tooltip. That is no longer a reason: the row's NAME is
-- an item link now (see _G.LootDrops.ItemLink), and a link carries the game's own tooltip and a
-- click of its own. So the icon only has to be a picture, and a picture is all this draws.
--
-- The way in is Shortcut:GetItem(), which turns an item shortcut into an Item without any slot
-- being involved. Its ItemInfo carries the image ids the client itself composes an icon from:
--
--     background   the slot backing
--     quality      the rarity backing -- OPAQUE, so it goes UNDER the art, not over it
--     icon         the item art itself, and therefore LAST
--
-- back to front. The order is the whole trick and it is not the order the getters are named in:
-- drawing quality last paints a flat coloured square over the item, which is exactly what the
-- first attempt did -- an olive green tile where a pair of boots should have been. Turbine draws
-- children in the order they are added, so the art is added last and nothing can cover it.
--
-- Everything is pcall'd and every layer is optional:
-- an id that resolves to nothing returns nil and leaves the caller to fall back, which is no
-- worse than the coloured bar this replaced.
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

-- Builds the layered icon into `parent` and returns it, or nil if the id resolves to nothing.
-- Mouse-invisible: the picture has no tooltip of its own and must not steal the row's hover
-- or the name link's click.
function _G.MakeItemIcon(parent, id, size)

    local images = ImageIds(id)
    if images == nil then return nil end

    local host = Turbine.UI.Control()
    host:SetParent(parent)
    host:SetSize(size, size)
    host:SetMouseVisible(false)

    -- ALPHABLEND, NOT THE DEFAULT. These are full-colour game images, and left on the default
    -- mode their alpha punches a hole straight through the window behind them. The same rule
    -- already applies to the class portraits in SidebarItems/CharacterItem.lua; Overlay is for
    -- the plugin's own white-on-transparent glyph .tga files and would render a game icon
    -- invisible (Ressources/ICONS.md).
    local function Layer(imageId)
        if imageId == nil then return end
        local layer = Turbine.UI.Control()
        layer:SetParent(host)
        layer:SetSize(size, size)
        layer:SetMouseVisible(false)
        layer:SetBlendMode(Turbine.UI.BlendMode.AlphaBlend)
        pcall(function() layer:SetBackground(imageId) end)
    end

    Layer(images.background)
    Layer(images.quality)
    Layer(images.icon)      -- last, so the item is on top of both backings

    return host

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

    -- The icon lives in here and is rebuilt per item, because it is composed of that item's own
    -- images. The host stays put so the layout never has to move.
    self.iconHost = Turbine.UI.Control()
    self.iconHost:SetParent(self)
    self.iconHost:SetSize(ICON, ICON)
    self.iconHost:SetPosition(RULE_W + GAP, math.floor((ROW_H - ICON) / 2))
    self.iconHost:SetMouseVisible(false)

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

-- The item's own art where its id resolves to some, and the quality bar where it does not --
-- an uncatalogued id is common and is not an error.
--
-- Rebuilt rather than re-pointed, because the layers ARE the item. Turbine has no destructor,
-- so the old one is reparented to nil and dropped.
function _G.LootRow:SetIcon(drop)

    if self.icon ~= nil then
        self.icon:SetParent(nil)
        self.icon = nil
    end

    self.icon = _G.MakeItemIcon(self.iconHost, drop and drop.id, ICON)

    if self.icon == nil then
        local bar = Turbine.UI.Control()
        bar:SetParent(self.iconHost)
        bar:SetPosition(math.floor((ICON - 3) / 2), 0)
        bar:SetSize(3, ICON)
        bar:SetBackColor(QualityColor(drop and drop.quality))
        bar:SetMouseVisible(false)
        self.icon = bar
    end

    -- THE STACK RIDES ON THE SLOT, the way the client draws it in a bag -- and it is the item's
    -- own art it belongs to, not the line of text beside it. Rebuilt with the icon because it is
    -- drawn over it.
    if self.stack ~= nil then
        self.stack:SetParent(nil)
        self.stack = nil
    end

    local quantity = self.item ~= nil and (self.item.quantity or 1) or 1

    if quantity > 1 then
        self.stack = Turbine.UI.Label()
        self.stack:SetParent(self.iconHost)
        self.stack:SetMultiline(false)
        self.stack:SetSize(ICON - 2, _G.Scaled(12))
        self.stack:SetPosition(0, ICON - _G.Scaled(12))
        self.stack:SetFont(_G.Font(9))
        self.stack:SetFontStyle(_G.Theme.FONT_STYLE)
        self.stack:SetForeColor(_G.Theme.TEXT)
        self.stack:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleRight)
        self.stack:SetText("\195\151" .. quantity)                 -- multiplication sign
        self.stack:SetMouseVisible(false)
    end

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
