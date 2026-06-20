

ContentItem = class(Turbine.UI.ListBox)
-- character item constructor --------------------------------------------------------------------------
function ContentItem:Constructor(content, index, sidebar)
	Turbine.UI.ListBox.Constructor( self )

    self.content = content
    self.index = index
    self.id = index
    self.name = content.name
    self.sidebar = sidebar
    self.searchText = ""

    if _G.Settings.content[self.index] == nil then
        _G.Settings.content[self.index] = {}
        _G.Settings.content[self.index].collapsed = false
    end
    self.settings = _G.Settings.content[self.index]

    self.hover = false
    self.isCollapsed = _G.Settings.content[self.index].collapsed

    self:Build()
    self:ApplySettings()
    self:ApplyCollapsed(self.isCollapsed)

end

function ContentItem:AddChild(child)

    self.children[#self.children+1] = child

end

function ContentItem:FillChildren()

    self:ClearItems()
    self:AddItem(self.blank)

    local lowerSearch = string.lower(self.searchText)
    local lowerName = string.lower(self.name)

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

    if not(self.isCollapsed) then
        self:SetHeight(44 * self:GetItemCount())
    end

end

function ContentItem:ClearChildren()

    self.children = {}
    self:ClearItems()
    self:AddItem(self.blank)

end

function ContentItem:SetSelected(value)

    if value then
        self.background1:SetBackColor(Turbine.UI.Color(0.28, 0.22, 0.08))
        self.contentName:SetForeColor(Turbine.UI.Color(1.0, 0.88, 0.55))
    else
        self.background1:SetBackColor(Turbine.UI.Color(0.10, 0.08, 0.04))
        self.contentName:SetForeColor(Turbine.UI.Color(0.73, 0.65, 0.50))
    end

end

function ContentItem:SetCollapsed(value)

    if value == nil then
        value = not(self.isCollapsed)
    end

    self.isCollapsed = value
    self:ApplyCollapsed(self.isCollapsed)

    _G.Settings.content[self.index].collapsed = value
    _G.SaveSettings()

end

function ContentItem:ApplyCollapsed(value)

    if value then
        self:SetHeight(38)
        self.collapsed:SetText(">")
    else
        self:SetHeight(44 * self:GetItemCount())
        self.collapsed:SetText("v")
    end

end

function ContentItem:Clicked()

    self.sidebar:ContentSelected(self)

end

function ContentItem:SizeChanged()

    local width, height = self:GetSize()

    self.blank:SetWidth(width)
    self.frame1:SetWidth(width - 60)
    self.background1:SetWidth(width - 62)
    self.contentName:SetWidth(width - 62)

end

function ContentItem:ApplySettings()

end

function ContentItem:Build()

    self:SetHeight(24)
    self:SetMouseVisible(false)

    self.blank = Turbine.UI.Control()
    self.blank:SetMouseVisible(false)
    self.blank:SetHeight(36)

    self.frame2 = Turbine.UI.Control()
    self.frame2:SetPosition(5, 12)
    self.frame2:SetParent(self.blank)
    self.frame2:SetBackColor(Turbine.UI.Color(0.40, 0.33, 0.20))
    self.frame2:SetSize(20, 20)

    self.background2 = Turbine.UI.Control()
    self.background2:SetPosition(1, 1)
    self.background2:SetParent(self.frame2)
    self.background2:SetBackColor(Turbine.UI.Color(0.10, 0.08, 0.04))
    self.background2:SetSize(18, 18)
    self.background2.MouseEnter = function ()
        self.hover = true
        self.frame2:SetBackColor(Turbine.UI.Color(0.65, 0.54, 0.28))
    end
    self.background2.MouseLeave = function ()
        self.hover = false
        self.frame2:SetBackColor(Turbine.UI.Color(0.40, 0.33, 0.20))
    end
    self.background2.MouseDown = function ()
        self.background2:SetBackColor(Turbine.UI.Color(0.22, 0.18, 0.08))
    end
    self.background2.MouseUp = function ()
        self.background2:SetBackColor(Turbine.UI.Color(0.10, 0.08, 0.04))
        if self.hover then
            self:SetCollapsed()
        end
    end

    self.collapsed = Turbine.UI.Label()
    self.collapsed:SetParent(self.background2)
    self.collapsed:SetSize(18, 18)
    self.collapsed:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter)
    self.collapsed:SetFontStyle(Turbine.UI.FontStyle.Outline)
    self.collapsed:SetFont(Turbine.UI.Lotro.Font.Verdana18)
    self.collapsed:SetText("v")
    self.collapsed:SetMouseVisible(false)
    self.collapsed:SetForeColor(Turbine.UI.Color(0.73, 0.65, 0.50))


    self.frame1 = Turbine.UI.Control()
    self.frame1:SetPosition(30, 12)
    self.frame1:SetParent(self.blank)
    self.frame1:SetBackColor(Turbine.UI.Color(0.40, 0.33, 0.20))
    self.frame1:SetHeight(20)

    self.background1 = Turbine.UI.Control()
    self.background1:SetPosition(1, 1)
    self.background1:SetParent(self.frame1)
    self.background1:SetBackColor(Turbine.UI.Color(0.10, 0.08, 0.04))
    self.background1:SetHeight(18)
    self.background1.MouseEnter = function ()
        self.hover = true
        self.frame1:SetBackColor(Turbine.UI.Color(0.65, 0.54, 0.28))
    end
    self.background1.MouseLeave = function ()
        self.hover = false
        self.frame1:SetBackColor(Turbine.UI.Color(0.40, 0.33, 0.20))
    end
    self.background1.MouseDown = function ()
        self.background1:SetBackColor(Turbine.UI.Color(0.22, 0.18, 0.08))
    end
    self.background1.MouseUp = function ()
        self.background1:SetBackColor(Turbine.UI.Color(0.10, 0.08, 0.04))
        if self.hover then
            self:Clicked()
        end
    end

    self.contentName = Turbine.UI.Label()
    self.contentName:SetParent(self.background1)
    self.contentName:SetHeight(18)
    self.contentName:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter)
    self.contentName:SetFontStyle(Turbine.UI.FontStyle.Outline)
    self.contentName:SetFont(Turbine.UI.Lotro.Font.Verdana18)
    self.contentName:SetText(self.name)
    self.contentName:SetMouseVisible(false)
    self.contentName:SetForeColor(Turbine.UI.Color(0.73, 0.65, 0.50))

    self:AddItem(self.blank)

end
