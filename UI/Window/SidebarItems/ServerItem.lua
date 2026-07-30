

local META_W    = 78
local HEADER_H  = 22
local CHILD_H   = 28   -- character row
local ICON      = 12   -- disclosure triangle
local MARK_W    = 2
local NAME_LEFT = 26
local PAD_RIGHT = 10

ServerItem = class(Turbine.UI.ListBox)
function ServerItem:Constructor(name, sidebar, displayName)
    Turbine.UI.ListBox.Constructor(self)

    self.name     = name
    self.id       = name
    -- the no-server group is displayed translated but still stored under a stable id,
    -- so its collapse state does not reset when the language changes
    self.display  = displayName or name
    self.sidebar  = sidebar
    self.searchText = ""

    if _G.Settings.servers[name] == nil then
        _G.Settings.servers[name] = {}
        _G.Settings.servers[name].collapsed = false
    end
    self.settings = _G.Settings.servers[name]

    self.hover    = false
    self.selected = false
    self.isCollapsed   = _G.Settings.servers[name].collapsed

    self:Build()
    self:ApplySettings()
    self:ApplyState()
    self:ApplyCollapsed(self.isCollapsed)
end

function ServerItem:AddChild(child)
    self.children[#self.children + 1] = child
end

function ServerItem:FillChildren()
    self:ClearItems()
    self:AddItem(self.blank)

    table.sort(self.children, function(a, b)
        local aLevel = a.character and a.character.level or 0
        local bLevel = b.character and b.character.level or 0
        if aLevel ~= bLevel then return aLevel > bLevel end
        return string.lower(a.name) < string.lower(b.name)
    end)

    local lowerSearch = string.lower(self.searchText)
    local lowerName   = string.lower(self.name)

    if self.searchText == "" or string.find(lowerName, lowerSearch, 1, true) then
        for _, child in ipairs(self.children) do
            self:AddItem(child)
        end
    else
        for _, child in ipairs(self.children) do
            if string.find(string.lower(child.name), lowerSearch, 1, true) then
                self:AddItem(child)
            end
        end
    end

    self:RefreshMeta()
    self:ApplyCollapsed(self.isCollapsed)
end

function ServerItem:RefreshMeta()

    local childCount = self:GetItemCount() - 1

    if self.searchText ~= "" then
        self.metaLabel:SetText(childCount .. " " .. _G.L("matchCount"))
    else
        self.metaLabel:SetText(tostring(childCount))
    end

    self:LayoutHeader()

end

function ServerItem:LayoutHeader()

    local width = self:GetWidth()
    if width <= 0 then return end

    self.blank:SetWidth(width)
    self.headerBg:SetWidth(width)
    self.metaLabel:SetLeft(width - PAD_RIGHT - META_W)

    local metaRoom = (self.metaLabel:GetText() ~= "") and (META_W + 8) or 0
    self.nameLabel:SetWidth(math.max(0, width - NAME_LEFT - PAD_RIGHT - metaRoom))

end


function ServerItem:ClearChildren()
    self.children = {}
    self:ClearItems()
    self:AddItem(self.blank)
end

function ServerItem:SetSelected(value)
    self.selected = value
    self:ApplyState()
end

function ServerItem:ApplyState()

    self.mark:SetVisible(self.selected == true)

    if self.selected then
        self.headerBg:SetBackColor(_G.Theme.SEL_BG)
        self.nameLabel:SetForeColor(_G.Theme.ACCENT)
    elseif self.hover then
        self.headerBg:SetBackColor(_G.Theme.FRAME)
        self.nameLabel:SetForeColor(_G.Theme.TEXT)
    else
        self.headerBg:SetBackColor(_G.Theme.SECTION)
        self.nameLabel:SetForeColor(_G.Theme.DIM2)
    end

end

function ServerItem:SetCollapsed(value)
    if value == nil then
        value = not self.isCollapsed
    end
    self.isCollapsed = value
    self:ApplyCollapsed(self.isCollapsed)
    _G.Settings.servers[self.name].collapsed = value
    _G.SaveSettings()
end

function ServerItem:ApplyCollapsed(value)
    -- a collapsed group still opens while a search is running, so its hits are visible
    if value and self.searchText == "" then
        self:SetHeight(HEADER_H)
        self.arrowIcon:SetBackground("LootLogs/Ressources/arrow_right.tga")
    else
        local childCount = self:GetItemCount() - 1
        self:SetHeight(HEADER_H + CHILD_H * childCount)
        self.arrowIcon:SetBackground("LootLogs/Ressources/arrow_down.tga")
    end
end

function ServerItem:Clicked()
    self.sidebar:ServerSelected(self)
end

function ServerItem:SizeChanged()
    if not self.blank then return end
    self:LayoutHeader()
end

function ServerItem:ApplySettings()
end

function ServerItem:Build()
    self:SetHeight(HEADER_H)
    self:SetMouseVisible(false)

    self.blank = Turbine.UI.Control()
    self.blank:SetMouseVisible(false)
    self.blank:SetHeight(HEADER_H)

    self.headerBg = Turbine.UI.Control()
    self.headerBg:SetParent(self.blank)
    self.headerBg:SetPosition(0, 0)
    self.headerBg:SetHeight(HEADER_H)
    self.headerBg:SetBackColor(_G.Theme.SECTION)
    self.headerBg.MouseEnter = function()
        self.hover = true
        self:ApplyState()
    end
    self.headerBg.MouseLeave = function()
        self.hover = false
        self:ApplyState()
    end
    self.headerBg.MouseClick = function()
        self:Clicked()
    end

    self.mark = Turbine.UI.Control()
    self.mark:SetParent(self.headerBg)
    self.mark:SetPosition(0, 0)
    self.mark:SetSize(MARK_W, HEADER_H)
    self.mark:SetBackColor(_G.Theme.ACCENT)
    self.mark:SetVisible(false)
    self.mark:SetMouseVisible(false)

    -- disclosure triangle; its own click target, so it does not also select the group
    self.arrowIcon = Turbine.UI.Control()
    self.arrowIcon:SetParent(self.headerBg)
    self.arrowIcon:SetPosition(6, math.floor((HEADER_H - ICON) / 2))
    self.arrowIcon:SetSize(ICON, ICON)
    self.arrowIcon:SetBackground("LootLogs/Ressources/arrow_down.tga")
    self.arrowIcon:SetBlendMode(Turbine.UI.BlendMode.Overlay)
    self.arrowIcon.MouseEnter = function()
        self.hover = true
        self:ApplyState()
    end
    self.arrowIcon.MouseLeave = function()
        self.hover = false
        self:ApplyState()
    end
    self.arrowIcon.MouseClick = function()
        self:SetCollapsed()
    end

    self.nameLabel = Turbine.UI.Label()
    self.nameLabel:SetMultiline(false)
    self.nameLabel:SetParent(self.headerBg)
    self.nameLabel:SetPosition(NAME_LEFT, 0)
    self.nameLabel:SetHeight(HEADER_H)
    self.nameLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
    self.nameLabel:SetFontStyle(_G.Theme.FONT_STYLE)
    self.nameLabel:SetFont(Turbine.UI.Lotro.Font.Verdana12)
    self.nameLabel:SetText(_G.Upper(self.display))
    self.nameLabel:SetForeColor(_G.Theme.DIM2)
    self.nameLabel:SetMouseVisible(false)

    self.metaLabel = Turbine.UI.Label()
    self.metaLabel:SetMultiline(false)
    self.metaLabel:SetParent(self.headerBg)
    self.metaLabel:SetTop(0)
    self.metaLabel:SetHeight(HEADER_H)
    self.metaLabel:SetWidth(META_W)
    self.metaLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleRight)
    self.metaLabel:SetFont(Turbine.UI.Lotro.Font.Verdana10)
    self.metaLabel:SetFontStyle(_G.Theme.FONT_STYLE)
    self.metaLabel:SetForeColor(_G.Theme.DIM)
    self.metaLabel:SetText("")
    self.metaLabel:SetMouseVisible(false)

    self:AddItem(self.blank)
end
