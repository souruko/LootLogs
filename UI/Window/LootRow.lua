-- One item row, shared by the loot popup and (from M3) the loot browser.
--
-- Turbine cannot measure a label and does not clip an oversized one, so every text column is
-- truncated with _G.Truncate against _G.GlyphWidth. Icons deliberately do not scale with the
-- Font Size setting: Turbine clips a .tga to its control rather than resizing it, so a scaled
-- icon box would crop the art.
--
-- Rows are built once and re-driven through SetLoot, because a popup that rebuilds its
-- controls on every chest leaks them -- Turbine has no destructor, only reparenting to nil.

-- A quickslot draws its art at 32px and CANNOT be scaled down -- SetStretchMode does not take
-- on it, whatever order it is called in. So the row is built around the slot rather than the
-- slot squeezed into the row: 32px icon box, and a row tall enough to seat it.
--
-- Like every other icon here it does not scale with the Font Size setting, because Turbine
-- clips art to its control instead of resizing it. The row height does scale, and is floored
-- so the slot always fits.
_G.LootSlotSize = 32

local PAD, ROW_H, ICON, RULE_W, GAP, META_W, STAR

local function Metrics()
    PAD    = _G.Scaled(8)
    GAP    = _G.Scaled(8)
    META_W = _G.Scaled(104)
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
-- Item quickslot -- the icon and tooltip route
-- ================================================================================================
-- Every place an item is named gets a quickslot, and a catalogued item's shortcut is put into it
-- from its id alone (_G.LootDrops.ShortcutData). That is what gives these windows real item
-- icons and the game's own tooltips, for items nobody in the group owns.
--
-- It is READ-ONLY. Dropping is off, so a slot cannot be overwritten by a stray drag and these
-- windows never touch the player's own quickslots or bags. The shortcut it carries comes from
-- the drops data and nowhere else.
--
-- `base` is kept on the control rather than captured, because popup rows are reused across
-- chests and a name captured at construction is wrong by the second chest.
function _G.MakeItemQuickslot(parent, base)

    local slot = Turbine.UI.Lotro.Quickslot()
    slot:SetParent(parent)

    -- Always 32. A quickslot ignores SetStretchMode, so there is no smaller size available and
    -- pretending otherwise just draws a full-size slot over the top of the row.
    slot:SetSize(_G.LootSlotSize, _G.LootSlotSize)

    slot:SetAllowDrop(false)
    slot.base = base

    -- a listing is for reading; a stray click must not fire the item it is showing
    pcall(function() slot:SetUseOnRightClick(false) end)

    return slot

end

-- Put the drops table's shortcut into a slot, which is the only way one ever gets there.
--
-- Silent on failure by design: a row whose item has no catalogued id simply shows an empty
-- slot, which is no worse than the bar it used to show.
function _G.ApplyItemShortcut(slot, drop)

    if slot == nil then return false end

    local data = _G.LootDrops.ShortcutData(drop)
    if data == nil then return false end

    local built, shortcut = pcall(function()
        return Turbine.UI.Lotro.Shortcut(_G.LootDrops.SHORTCUT_ITEM, data)
    end)

    if not built or shortcut == nil then return false end

    return pcall(function() slot:SetShortcut(shortcut) end)

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

    -- the icon: a read-only quickslot carrying the item's own shortcut, so the row shows the
    -- real art and the game's own tooltip
    self.quickslot = _G.MakeItemQuickslot(self, nil)
    self.quickslot:SetPosition(RULE_W + GAP, math.floor((ROW_H - ICON) / 2))

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
    self.nameLabel:SetMouseVisible(false)

    self.metaLabel = Turbine.UI.Label()
    self.metaLabel:SetParent(self)
    self.metaLabel:SetMultiline(false)
    self.metaLabel:SetHeight(ROW_H)
    self.metaLabel:SetFont(_G.Font(10))
    self.metaLabel:SetFontStyle(_G.Theme.FONT_STYLE)
    self.metaLabel:SetForeColor(_G.Theme.DIM2)
    self.metaLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleRight)
    self.metaLabel:SetMouseVisible(false)

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

    self.nameLabel:SetPosition(nameX, 0)
    self.nameLabel:SetHeight(height)
    self.nameLabel:SetWidth(math.max(0, width - nameX - META_W - PAD))

    self.metaLabel:SetPosition(math.max(0, width - META_W - PAD), 0)
    self.metaLabel:SetHeight(height)
    self.metaLabel:SetWidth(META_W)

end

-- Text has to be re-cut whenever the row's width changes, because Turbine cannot measure a
-- label: the truncation is computed from the width at the moment it is applied. A row that
-- is filled before its first layout would otherwise measure against a near-zero width and
-- keep the stub it produced, however wide the row later became.
function _G.LootRow:RefreshText()

    local item = self.item
    if item == nil then return end

    self:LayoutLabels()

    -- Count and name are truncated as ONE string, so a name too long for the column loses its
    -- tail and never its "3x". The star is a separate control and takes its own space.
    local quantity = (item.quantity or 1) > 1 and (item.quantity .. "x ") or ""
    local shown    = _G.LootDrops.DisplayName(self.drop, item.base)

    self.nameLabel:SetText(_G.Truncate(
        quantity .. shown,
        self.nameLabel:GetWidth(),
        _G.GlyphWidth(12)))

    local meta = item.player or ""
    if item.level then
        meta = tostring(item.level) .. _G.Sep .. meta
    end
    self.metaLabel:SetText(_G.Truncate(meta, META_W, _G.GlyphWidth(10)))

end

-- item: { base, level, quantity, player, isSelf }, drop: the _G.Drops row (may be nil)
function _G.LootRow:SetLoot(item, drop)

    self.item = item
    self.drop = drop

    -- LootStats may not be loaded yet; the row must not require it
    local wished = _G.LootStats ~= nil and _G.LootStats.IsWished(item.base) or false

    -- set before RefreshText, because the star's presence decides where the name starts
    self.star:SetVisible(wished)

    if item.isSelf then
        self:SetBackColor(_G.Theme.CHIP_FAV_BG)
        self.rule:SetBackColor(_G.Theme.ACCENT)
        self.nameLabel:SetForeColor(_G.Theme.CHIP_FAV_TEXT)
        self.metaLabel:SetForeColor(_G.Theme.ACCENT)
    else
        self:SetBackColor(wished and _G.Theme.CHIP_FAV_BG or _G.Theme.BG)
        self.rule:SetBackColor(_G.Theme.FRAME)
        self.nameLabel:SetForeColor(QualityColor(drop and drop.quality))
        self.metaLabel:SetForeColor(_G.Theme.DIM2)
    end

    -- rows are reused across chests, so the slot is re-pointed rather than rebuilt
    if self.quickslot ~= nil then
        self.quickslot.base = item.base
        _G.ApplyItemShortcut(self.quickslot, drop)
    end

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
