

ServerItem = class(Turbine.UI.ListBox)
function ServerItem:Constructor(name, sidebar)
    Turbine.UI.ListBox.Constructor(self)

    self.name     = name
    self.id       = name
    self.sidebar  = sidebar
    self.searchText = ""

    if _G.Settings.servers[name] == nil then
        _G.Settings.servers[name] = {}
        _G.Settings.servers[name].collapsed = false
    end
    self.settings = _G.Settings.servers[name]

    self.collapseHover = false
    self.nameHover     = false
    self.isCollapsed   = _G.Settings.servers[name].collapsed

    self:Build()
    self:ApplySettings()
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

    if not self.isCollapsed then
        local childCount = self:GetItemCount() - 1
        self:SetHeight(38 + 44 * childCount)
    end
end

function ServerItem:ClearChildren()
    self.children = {}
    self:ClearItems()
    self:AddItem(self.blank)
end

function ServerItem:SetSelected(value)
    if value then
        self.headerBg:SetBackColor(_G.Theme.SEL_BG)
        self.nameLabel:SetForeColor(_G.Theme.ACCENT)
    else
        self.headerBg:SetBackColor(_G.Theme.HEADER)
        self.nameLabel:SetForeColor(_G.Theme.TEXT)
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
    if value then
        self:SetHeight(38)
        self.arrowIcon:SetBackground("LootLogsBeta/Ressources/arrow_right.tga")
    else
        local childCount = self:GetItemCount() - 1
        self:SetHeight(38 + 44 * childCount)
        self.arrowIcon:SetBackground("LootLogsBeta/Ressources/arrow_down.tga")
    end
end

function ServerItem:Clicked()
    self.sidebar:ServerSelected(self)
end

function ServerItem:SizeChanged()
    if not self.blank then return end
    local width = self:GetWidth()
    self.blank:SetWidth(width)
    self.accentStrip:SetWidth(width - 12)
    self.headerFrame:SetWidth(width - 12)
    self.headerBg:SetWidth(width - 14)
    self.nameBtn:SetWidth(width - 41)
    self.nameLabel:SetWidth(width - 41)
end

function ServerItem:ApplySettings()
end

function ServerItem:Build()
    self:SetHeight(38)
    self:SetMouseVisible(false)

    self.blank = Turbine.UI.Control()
    self.blank:SetMouseVisible(false)
    self.blank:SetHeight(38)

    self.accentStrip = Turbine.UI.Control()
    self.accentStrip:SetParent(self.blank)
    self.accentStrip:SetPosition(0, 6)
    self.accentStrip:SetHeight(2)
    self.accentStrip:SetBackColor(_G.Theme.STRIP)
    self.accentStrip:SetMouseVisible(false)

    -- single unified header bar
    self.headerFrame = Turbine.UI.Control()
    self.headerFrame:SetParent(self.blank)
    self.headerFrame:SetPosition(0, 8)
    self.headerFrame:SetHeight(28)
    self.headerFrame:SetBackColor(_G.Theme.FRAME)

    self.headerBg = Turbine.UI.Control()
    self.headerBg:SetParent(self.headerFrame)
    self.headerBg:SetPosition(1, 1)
    self.headerBg:SetHeight(26)
    self.headerBg:SetBackColor(_G.Theme.HEADER)
    self.headerBg:SetMouseVisible(false)

    -- collapse button (left 26px of header)
    self.arrowBtn = Turbine.UI.Control()
    self.arrowBtn:SetParent(self.headerFrame)
    self.arrowBtn:SetPosition(1, 1)
    self.arrowBtn:SetSize(26, 26)
    self.arrowBtn.MouseEnter = function()
        self.collapseHover = true
        self.headerFrame:SetBackColor(_G.Theme.HOVER)
    end
    self.arrowBtn.MouseLeave = function()
        self.collapseHover = false
        if not self.nameHover then
            self.headerFrame:SetBackColor(_G.Theme.FRAME)
        end
    end
    self.arrowBtn.MouseUp = function()
        if self.collapseHover then
            self:SetCollapsed()
        end
    end

    self.arrowIcon = Turbine.UI.Control()
    self.arrowIcon:SetParent(self.arrowBtn)
    self.arrowIcon:SetSize(20, 20)
    self.arrowIcon:SetBackground("LootLogsBeta/Ressources/arrow_down.tga")
    self.arrowIcon:SetBlendMode(Turbine.UI.BlendMode.Overlay)
    self.arrowIcon:SetMouseVisible(false)

    -- name / select area (fills rest of header)
    self.nameBtn = Turbine.UI.Control()
    self.nameBtn:SetParent(self.headerFrame)
    self.nameBtn:SetPosition(28, 1)
    self.nameBtn:SetHeight(26)
    self.nameBtn.MouseEnter = function()
        self.nameHover = true
        self.headerFrame:SetBackColor(_G.Theme.HOVER)
    end
    self.nameBtn.MouseLeave = function()
        self.nameHover = false
        if not self.collapseHover then
            self.headerFrame:SetBackColor(_G.Theme.FRAME)
        end
    end
    self.nameBtn.MouseDown = function()
        self.headerBg:SetBackColor(_G.Theme.SEL_BG)
    end
    self.nameBtn.MouseUp = function()
        self.headerBg:SetBackColor(_G.Theme.HEADER)
        if self.nameHover then
            self:Clicked()
        end
    end

    self.nameLabel = Turbine.UI.Label()
    self.nameLabel:SetParent(self.nameBtn)
    self.nameLabel:SetHeight(26)
    self.nameLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
    self.nameLabel:SetFontStyle(_G.Theme.FONT_STYLE)
    self.nameLabel:SetFont(Turbine.UI.Lotro.Font.Verdana16)
    self.nameLabel:SetText(self.name)
    self.nameLabel:SetForeColor(_G.Theme.TEXT)
    self.nameLabel:SetMouseVisible(false)

    self:AddItem(self.blank)
end
