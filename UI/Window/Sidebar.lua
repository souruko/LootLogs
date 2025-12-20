

Sidebar = class(Turbine.UI.Control)
-- window constructor --------------------------------------------------------------------------
function Sidebar:Constructor()
	Turbine.UI.Control.Constructor( self )

    self.background1 = Turbine.UI.Control()
    self.frame1 = Turbine.UI.Control()
    self.background2 = Turbine.UI.Control()
    self.filter = Turbine.UI.Lotro.TextBox()
    self.background3 = Turbine.UI.Control()
    self.collapseAll = Turbine.UI.Label()
    self.frame2 = Turbine.UI.Control()
    self.background4 = Turbine.UI.Control()
    self.todo = Turbine.UI.Label()
    self.frame3 = Turbine.UI.Control()
    self.background5 = Turbine.UI.Control()
    self.content = Turbine.UI.Label()
    self.frame4 = Turbine.UI.Control()
    self.background6 = Turbine.UI.Control()
    self.characters = Turbine.UI.Label()
    self.background7 = Turbine.UI.Control()

    self.toDoSelected = true
    self.contentSelected = false
    self.characterSelected = true

    self.selectedContent = nil
    self.selectedCharacter = nil

    self.todoHover = false
    self.collapseHover = false
    self.contentHover = false
    self.characterHover = false

    self:ApplySettings()
    self:UpdateSelection(true, false, false)

end

function Sidebar:UpdateSelection(isTodo, isContent, isCharacter, id)

    if isTodo then
        if self.toDoSelected then
            self.toDoSelected = false
        else
            self.toDoSelected = true
        end
    elseif isContent then
        self.toDoSelected = false
        self.contentSelected = true
        self.characterSelected = false
        if id then
            self.selectedContent = id
        end
    elseif isCharacter then
        self.toDoSelected = false
        self.contentSelected = false
        self.characterSelected = true
        if id then
            self.selectedCharacter = id
        end
    end

    self:UpdateSelectionVisual()

end

function Sidebar:UpdateSelectionVisual()

    if self.toDoSelected then
        self.background4:SetBackColor(Turbine.UI.Color(0.2, 0.2, 0.2))
        self.todo:SetForeColor(Turbine.UI.Color(0.8, 0.8, 0.8))
    else
        self.background4:SetBackColor(Turbine.UI.Color.Black)
        self.todo:SetForeColor(Turbine.UI.Color(0.6, 0.6, 0.6))
    end

    if self.contentSelected then
        self.background5:SetBackColor(Turbine.UI.Color(0.2, 0.2, 0.2))
        self.content:SetForeColor(Turbine.UI.Color(0.8, 0.8, 0.8))
    else
        self.background5:SetBackColor(Turbine.UI.Color.Black)
        self.content:SetForeColor(Turbine.UI.Color(0.6, 0.6, 0.6))
    end

    if self.characterSelected then
        self.background6:SetBackColor(Turbine.UI.Color(0.2, 0.2, 0.2))
        self.characters:SetForeColor(Turbine.UI.Color(0.8, 0.8, 0.8))
    else
        self.background6:SetBackColor(Turbine.UI.Color.Black)
        self.characters:SetForeColor(Turbine.UI.Color(0.6, 0.6, 0.6))
    end

end

function Sidebar:SizeChanged()
    
    local width, height = self:GetSize()

    self.background1:SetSize(width - 10, height - 10)
    self.frame1:SetSize(width - 20, height - 20)

    -- todo
    self.frame2:SetWidth(width - 22)
    self.background4:SetWidth(width - 24)
    self.todo:SetWidth(width - 22)

    -- content / character toggle
    self.frame3:SetWidth(math.floor((width - 22) / 2))
    self.background5:SetWidth(math.floor((width - 22) / 2) - 2)
    self.content:SetWidth(self.background5:GetWidth())

    self.frame4:SetLeft(self.background5:GetWidth() + 4)
    self.frame4:SetWidth(width - self.frame4:GetLeft() - 21)
    self.background6:SetWidth(self.frame4:GetWidth() - 2)
    self.characters:SetWidth(self.background6:GetWidth())
 
    -- filter
    self.background2:SetWidth(width - 43)
    self.filter:SetWidth(width - 43)

    -- collapse button
    self.background3:SetLeft(width - 41)

    -- select
    self.background7:SetSize(width - 22, height - self.background7:GetTop() - 21)

end

function Sidebar:ApplySettings()
    
	self:SetBackColor(Turbine.UI.Color(0.2, 0.2, 0.2))

    self.background1:SetParent(self)
    self.background1:SetBackColor(Turbine.UI.Color.Black)
    self.background1:SetPosition(5, 5)
 
    self.frame1:SetParent(self.background1)
    self.frame1:SetBackColor(Turbine.UI.Color(0.4, 0.4, 0.4))
    self.frame1:SetPosition(5, 5)

    local top = 1

    -- todo
    if _G.Settings.showToDo == true then

        self.frame2:SetParent(self.frame1)
        self.frame2:SetBackColor(Turbine.UI.Color.Black)
        self.frame2:SetPosition(5, 5)
        self.frame2:SetHeight(30)
        self.frame2:SetPosition(1, top)

        self.background4:SetParent(self.frame2)
        self.background4:SetBackColor(Turbine.UI.Color.Black)
        self.background4:SetPosition(1, 1)
        self.background4:SetHeight(28)
        self.background4.MouseEnter = function ()
            self.todoHover = true
            self.frame2:SetBackColor(Turbine.UI.Color(0.7, 0.7, 0.7))
        end
        self.background4.MouseLeave = function ()
            self.todoHover = false
            self.frame2:SetBackColor(Turbine.UI.Color.Black)
        end
        self.background4.MouseDown = function ()
            self.background4:SetBackColor(Turbine.UI.Color(0.3, 0.3, 0.3))
        end
        self.background4.MouseUp = function ()
            self.background4:SetBackColor(Turbine.UI.Color.Black)
            if self.todoHover then
                self:UpdateSelection(true, false, false, nil)
            end
        end

        self.todo:SetParent(self.background4)
        self.todo:SetHeight(28)
        self.todo:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter)
        self.todo:SetFont(Turbine.UI.Lotro.Font.Verdana16)
        self.todo:SetFontStyle(Turbine.UI.FontStyle.Outline)
        self.todo:SetText("ToDo")
        self.todo:SetMouseVisible(false)
        self.todo:SetForeColor(Turbine.UI.Color(0.6, 0.6, 0.6))

        top = top + 31
    end

    -- content / character toggle
    self.frame3:SetParent(self.frame1)
    self.frame3:SetBackColor(Turbine.UI.Color.Black)
    self.frame3:SetPosition(1, top)
    self.frame3:SetHeight(20)
    self.frame3:SetPosition(1, top)

    self.background5:SetParent(self.frame3)
    self.background5:SetBackColor(Turbine.UI.Color.Black)
    self.background5:SetPosition(1, 1)
    self.background5:SetHeight(18)
    self.background5.MouseEnter = function ()
        self.contentHover = true
        self.frame3:SetBackColor(Turbine.UI.Color(0.7, 0.7, 0.7))
    end
    self.background5.MouseLeave = function ()
        self.contentHover = false
        self.frame3:SetBackColor(Turbine.UI.Color.Black)
    end
    self.background5.MouseDown = function ()
        self.background5:SetBackColor(Turbine.UI.Color(0.3, 0.3, 0.3))
    end
    self.background5.MouseUp = function ()
        self.background5:SetBackColor(Turbine.UI.Color.Black)
        if self.contentHover then
            self:UpdateSelection(false, true, false, nil)
        end
    end

    self.content:SetParent(self.background5)
    self.content:SetHeight(18)
    self.content:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter)
    self.content:SetFont(Turbine.UI.Lotro.Font.Verdana16)
    self.content:SetText("Content")
    self.content:SetMouseVisible(false)
    self.content:SetFontStyle(Turbine.UI.FontStyle.Outline)
    self.content:SetForeColor(Turbine.UI.Color(0.6, 0.6, 0.6))

    self.frame4:SetParent(self.frame1)
    self.frame4:SetBackColor(Turbine.UI.Color.Black)
    self.frame4:SetTop(top)
    self.frame4:SetHeight(20)
    self.frame4:SetPosition(1, top)

    self.background6:SetParent(self.frame4)
    self.background6:SetBackColor(Turbine.UI.Color.Black)
    self.background6:SetPosition(1, 1)
    self.background6:SetHeight(18)
    self.background6.MouseEnter = function ()
        self.characterHover = true
        self.frame4:SetBackColor(Turbine.UI.Color(0.7, 0.7, 0.7))
    end
    self.background6.MouseLeave = function ()
        self.characterHover = false
        self.frame4:SetBackColor(Turbine.UI.Color.Black)
    end
    self.background6.MouseDown = function ()
        self.background6:SetBackColor(Turbine.UI.Color(0.3, 0.3, 0.3))
    end
    self.background6.MouseUp = function ()
        self.background6:SetBackColor(Turbine.UI.Color.Black)
        if self.characterHover then
            self:UpdateSelection(false, false, true, nil)
        end
    end

    self.characters:SetParent(self.background6)
    self.characters:SetHeight(18)
    self.characters:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter)
    self.characters:SetFont(Turbine.UI.Lotro.Font.Verdana16)
    self.characters:SetText("Characters")
    self.characters:SetMouseVisible(false)
    self.characters:SetFontStyle(Turbine.UI.FontStyle.Outline)
    self.characters:SetForeColor(Turbine.UI.Color(0.6, 0.6, 0.6))

    top = top + 21

    -- filter
    self.background2:SetParent(self.frame1)
    self.background2:SetBackColor(Turbine.UI.Color(0.1, 0.1, 0.1))
    self.background2:SetPosition(1, top)
    self.background2:SetHeight(20)

    self.filter:SetParent(self.background2)
    self.filter:SetHeight(20)
    self.filter:SetFont(Turbine.UI.Lotro.Font.Verdana12)
    self.filter:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
    self.filter:SetMultiline(false)
    self.filter:SetForeColor(Turbine.UI.Color(0.6, 0.6, 0.6))
    self.filter:SetText("search ...")

    -- collapse button
    self.background3:SetParent(self.frame1)
    self.background3:SetBackColor(Turbine.UI.Color(0.1, 0.1, 0.1))
    self.background3:SetTop(top)
    self.background3:SetSize(20, 20)
    self.background3.MouseEnter = function ()
        self.collapseHover = true
        self.background3:SetBackColor(Turbine.UI.Color(0.2, 0.2, 0.2))
    end
    self.background3.MouseLeave = function ()
        self.collapseHover = false
        self.background3:SetBackColor(Turbine.UI.Color.Black)
    end
    self.background3.MouseDown = function ()
        self.background3:SetBackColor(Turbine.UI.Color(0.3, 0.3, 0.3))
    end
    self.background3.MouseUp = function ()
        if self.collapseHover then
            self.background3:SetBackColor(Turbine.UI.Color(0.2, 0.2, 0.2))
        end
    end

    self.collapseAll:SetParent(self.background3)
    self.collapseAll:SetSize(20, 20)
    self.collapseAll:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter)
    self.collapseAll:SetFont(Turbine.UI.Lotro.Font.Verdana16)
    self.collapseAll:SetText("C")
    self.collapseAll:SetMouseVisible(false)
    self.collapseAll:SetFontStyle(Turbine.UI.FontStyle.Outline)
    self.collapseAll:SetForeColor(Turbine.UI.Color(0.6, 0.6, 0.6))

    top = top + 21

    -- select
    self.background7:SetParent(self.frame1)
    self.background7:SetBackColor(Turbine.UI.Color(0.1, 0.1, 0.1))
    self.background7:SetPosition(1, top)

end