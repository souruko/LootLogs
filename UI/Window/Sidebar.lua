
import "LootLogs2.UI.Window.SidebarItems.CharacterItem"
import "LootLogs2.UI.Window.SidebarItems.InstanceItem"

import "LootLogs2.UI.Window.SidebarItems.ContentItem"
import "LootLogs2.UI.Window.SidebarItems.ServerItem"

Sidebar = class(Turbine.UI.Control)
-- window constructor --------------------------------------------------------------------------
function Sidebar:Constructor()
	Turbine.UI.Control.Constructor( self )

    self:Build()
    self:ApplySettings()

    self.toDoSelected = nil
    self.contentSelected = false
    self.characterSelected = false
    self.selectedContent = nil
    self.selectedInstance = nil

    self.selectedServer = nil
    self.selectedCharacter = nil

    self.todoHover = false
    self.collapseHover = false
    self.contentHover = false
    self.characterHover = false

    self.characterItems = {}
    self.contenItems = {}
    self.serverItems = {}

    self:CreateInstanceItems()
    self:CreateContentItems()

    self:CreateCharacterItems()
    self:CreateServerItems()

    local contentSelected = _G.Settings.selected.tab == _G.Tab.Content
    local characterSelected = _G.Settings.selected.tab == _G.Tab.Characters
    self:UpdateSelection(_G.Settings.selected.todo, contentSelected, characterSelected)

end

function Sidebar:InstanceSelected(selectedItem)

    self:UpdateSelection(false, true, false)
    self.selectedInstance = selectedItem
    self.selectedContent = nil

    _G.Settings.selected.tab = _G.Tab.Content
    _G.Settings.selected.instance = selectedItem.id
    _G.Settings.selected.content = nil
    _G.SaveSettings()

    for _, item in ipairs(self.contenItems) do
        item:SetSelected(false)
    end
    for _, item in ipairs(self.instanceItems) do
        item:SetSelected(item == selectedItem)
    end

    self:GetParent():SelectionChanged()

end

function Sidebar:ContentSelected(selectedItem)

    self:UpdateSelection(false, true, false)
    self.selectedInstance = nil
    self.selectedContent = selectedItem

    _G.Settings.selected.tab = _G.Tab.Content
    _G.Settings.selected.instance = nil
    _G.Settings.selected.content = selectedItem.id
    _G.SaveSettings()

    for _, item in ipairs(self.contenItems) do
        item:SetSelected(item == selectedItem)
    end

    for _, item in ipairs(self.instanceItems) do
        item:SetSelected(false)
    end

    self:GetParent():SelectionChanged()

end

function Sidebar:CharacterSelected(selectedItem)

    self:UpdateSelection(false, false, true)
    self.selectedCharacter = selectedItem
    self.selectedServer = nil

    _G.Settings.selected.tab = _G.Tab.Characters
    _G.Settings.selected.character = selectedItem.id
    _G.Settings.selected.server = nil
    _G.SaveSettings()


    for _, item in ipairs(self.serverItems) do
        item:SetSelected(false)
    end
    for _, item in ipairs(self.characterItems) do
        item:SetSelected(item == selectedItem)
    end

    self:GetParent():SelectionChanged()

end

function Sidebar:ServerSelected(selectedItem)

    self:UpdateSelection(false, false, true)
    self.selectedCharacter = nil
    self.selectedServer = selectedItem

    _G.Settings.selected.tab = _G.Tab.Characters
    _G.Settings.selected.character = nil
    _G.Settings.selected.server = selectedItem.id
    _G.SaveSettings()

    for _, item in ipairs(self.serverItems) do
        item:SetSelected(item == selectedItem)
    end

    for _, item in ipairs(self.characterItems) do
        item:SetSelected(false)
    end

    self:GetParent():SelectionChanged()

end

function Sidebar:FindItemById(id, items)

    for key, item in pairs(items) do
        if item.id == id then
            return item
        end
    end

    return nil

end

function Sidebar:CreateContentItems()

    self.contenItems = {}

    for contentIndex, content in ipairs(_G.Content) do
        local index = #self.contenItems+1
        self.contenItems[index] = SidebarItems.ContentItem(content, contentIndex, self)
    end

    -- no server selected
    local index = #self.serverItems+1
    self.serverItems[index] = SidebarItems.ServerItem("No Server Selected", self)

    self.selectedContent = self:FindItemById(_G.Settings.selected.content, self.contenItems)

    if self.selectedContent then
        self.selectedContent:SetSelected(true)
    end

end

function Sidebar:CreateInstanceItems()

    self.instanceItems = {}

    for id, instance in pairs(_G.Instances) do
        local index = #self.instanceItems+1
        self.instanceItems[index] = SidebarItems.InstanceItem(id, instance, self)
    end

    self.selectedInstance = self:FindItemById(_G.Settings.selected.instance, self.instanceItems)

    if self.selectedInstance then
        self.selectedInstance:SetSelected(true)
    end

end

function Sidebar:CreateCharacterItems()

    self.characterItems = {}

    for id, character in pairs(_G.Logs) do

        if character.enabled then
            local index = #self.characterItems+1
            self.characterItems[index] = SidebarItems.CharacterItem(id, character, self)
        end
    end

    self.selectedCharacter = self:FindItemById(_G.Settings.selected.character, self.characterItems)

    if self.selectedCharacter then
        self.selectedCharacter:SetSelected(true)
    end

end

function Sidebar:CreateServerItems()

    self.serverItems = {}

    local serverList = _G.GetServerList()

    for serverIndex, name in ipairs(serverList) do
        local index = #self.serverItems+1
        self.serverItems[index] = SidebarItems.ServerItem(name, self)
    end

    -- no server selected
    local index = #self.serverItems+1
    self.serverItems[index] = SidebarItems.ServerItem("No Server Selected", self)

    self.selectedServer = self:FindItemById(_G.Settings.selected.server, self.serverItems)

    if self.selectedServer then
        self.selectedServer:SetSelected(true)
    end

end

function Sidebar:FillContentItems()

    self.itemView:ClearItems()
    for _, item in pairs(self.contenItems) do
        item:ClearChildren()
    end

    for _, contentItem in pairs(self.contenItems) do
        self.itemView:AddItem(contentItem)
        for _, instanceItem in pairs(self.instanceItems) do
            if instanceItem.instance.content == contentItem.index then
                contentItem:AddChild(instanceItem)
            end
        end
        contentItem:FillChildren()
    end

end

function Sidebar:FillCharacterItems()

    self.itemView:ClearItems()
    for _, item in pairs(self.serverItems) do
        item:ClearChildren()
    end

    if _G.Settings.showServers then
        for index, serverItem in pairs(self.serverItems) do
            self.itemView:AddItem(serverItem)
            for cIndex, characterItem in pairs(self.characterItems) do
                if characterItem.character.server == serverItem.name then
                    serverItem:AddChild(characterItem)
                end
            end
            serverItem:FillChildren()
        end
        local noServerItem = self.serverItems[#self.serverItems]
        for index, characterItem in pairs(self.characterItems) do
            if characterItem.character.server == nil then
                noServerItem:AddChild(characterItem)
            end
        end
        noServerItem:FillChildren()

    else
        for index, item in pairs(self.characterItems) do
            self.itemView:AddItem(item)
        end

    end


end

function Sidebar:UpdateSelection(isTodo, isContent, isCharacter)

    if isTodo then
        if self.toDoSelected then
            self.toDoSelected = false
        else
            self.toDoSelected = true
        end
    end

    if isContent then
        if self.contentSelected == false then
            self:FillContentItems()
        end

        self.toDoSelected = false
        self.contentSelected = true
        self.characterSelected = false

    elseif isCharacter then
        if self.characterSelected == false then
            self:FillCharacterItems()
        end

        self.toDoSelected = false
        self.contentSelected = false
        self.characterSelected = true
    end

    self:UpdateSelectionVisual()

end

function Sidebar:UpdateSelectionVisual()

    if self.toDoSelected then
        self.background4:SetBackColor(Turbine.UI.Color(0.22, 0.18, 0.08))
        self.todo:SetForeColor(Turbine.UI.Color(1.0, 0.88, 0.55))
    else
        self.background4:SetBackColor(Turbine.UI.Color(0.05, 0.04, 0.03))
        self.todo:SetForeColor(Turbine.UI.Color(0.52, 0.45, 0.32))
    end

    if self.contentSelected then
        self.background5:SetBackColor(Turbine.UI.Color(0.22, 0.18, 0.08))
        self.content:SetForeColor(Turbine.UI.Color(1.0, 0.88, 0.55))
    else
        self.background5:SetBackColor(Turbine.UI.Color(0.05, 0.04, 0.03))
        self.content:SetForeColor(Turbine.UI.Color(0.52, 0.45, 0.32))
    end

    if self.characterSelected then
        self.background6:SetBackColor(Turbine.UI.Color(0.22, 0.18, 0.08))
        self.characters:SetForeColor(Turbine.UI.Color(1.0, 0.88, 0.55))
    else
        self.background6:SetBackColor(Turbine.UI.Color(0.05, 0.04, 0.03))
        self.characters:SetForeColor(Turbine.UI.Color(0.52, 0.45, 0.32))
    end

end

function Sidebar:CollapseAll()

    for index, item in ipairs(self.serverItems) do
        item:SetCollapsed(true)
    end

    -- for index, item in ipairs(self.contentItems) do
    --     item:SetCollapsed(true)
    -- end

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
    self.itemView:SetSize(width - 22, height - self.itemView:GetTop() - 21)
    self.itemScrollbar:SetHeight(self.itemView:GetHeight())
    self.itemScrollbar:SetLeft(width - 32)

    -- items
    for index, item in pairs(self.characterItems) do
        item:SetWidth(width - 22)
    end
    for index, item in pairs(self.instanceItems) do
        item:SetWidth(width - 22)
    end


    for index, item in pairs(self.serverItems) do
        item:SetWidth(width - 22)
    end
    for index, item in pairs(self.contenItems) do
        item:SetWidth(width - 22)
    end

end

function Sidebar:ApplySettings()

    local top = 1

    -- todo
    if _G.Settings.showToDo == true then

        self.frame2:SetPosition(1, top)
        self.frame2:SetVisible(true)
        self.background4:SetVisible(true)
        self.todo:SetVisible(true)
        top = top + 31

    else

        self.frame2:SetVisible(false)
        self.background4:SetVisible(false)
        self.todo:SetVisible(false)

    end

    -- content / character toggle
    self.frame3:SetPosition(1, top)
    self.frame4:SetPosition(1, top)

    top = top + 31

    -- filter
    self.background2:SetPosition(1, top)

    -- collapse button
    self.background3:SetTop(top)
    top = top + 21

    -- select
    self.itemView:SetPosition(1, top)

end

function Sidebar:Build()

    -- base background: warm dark brown outer ring
	self:SetBackColor(Turbine.UI.Color(0.22, 0.18, 0.12))

    self.background1 = Turbine.UI.Control()
    self.background1:SetParent(self)
    self.background1:SetBackColor(Turbine.UI.Color(0.05, 0.04, 0.03))
    self.background1:SetPosition(5, 5)

    self.frame1 = Turbine.UI.Control()
    self.frame1:SetParent(self.background1)
    self.frame1:SetBackColor(Turbine.UI.Color(0.40, 0.33, 0.20))
    self.frame1:SetPosition(5, 5)

    -- todo row
    self.frame2 = Turbine.UI.Control()
    self.frame2:SetParent(self.frame1)
    self.frame2:SetBackColor(Turbine.UI.Color(0.05, 0.04, 0.03))
    self.frame2:SetHeight(30)

    self.background4 = Turbine.UI.Control()
    self.background4:SetParent(self.frame2)
    self.background4:SetBackColor(Turbine.UI.Color(0.05, 0.04, 0.03))
    self.background4:SetPosition(1, 1)
    self.background4:SetHeight(28)
    self.background4.MouseEnter = function ()
        self.todoHover = true
        self.frame2:SetBackColor(Turbine.UI.Color(0.65, 0.54, 0.28))
    end
    self.background4.MouseLeave = function ()
        self.todoHover = false
        self.frame2:SetBackColor(Turbine.UI.Color(0.05, 0.04, 0.03))
    end
    self.background4.MouseDown = function ()
        self.background4:SetBackColor(Turbine.UI.Color(0.18, 0.15, 0.08))
    end
    self.background4.MouseUp = function ()
        self.background4:SetBackColor(Turbine.UI.Color(0.05, 0.04, 0.03))
        if self.todoHover then
            self:UpdateSelection(true, false, false)
        end
    end

    self.todo = Turbine.UI.Label()
    self.todo:SetParent(self.background4)
    self.todo:SetHeight(28)
    self.todo:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter)
    self.todo:SetFont(Turbine.UI.Lotro.Font.Verdana16)
    self.todo:SetFontStyle(Turbine.UI.FontStyle.Outline)
    self.todo:SetText("ToDo")
    self.todo:SetMouseVisible(false)
    self.todo:SetForeColor(Turbine.UI.Color(0.52, 0.45, 0.32))

    -- content / characters row
    self.frame3 = Turbine.UI.Control()
    self.frame3:SetParent(self.frame1)
    self.frame3:SetBackColor(Turbine.UI.Color(0.05, 0.04, 0.03))
    self.frame3:SetHeight(30)

    self.background5 = Turbine.UI.Control()
    self.background5:SetParent(self.frame3)
    self.background5:SetBackColor(Turbine.UI.Color(0.05, 0.04, 0.03))
    self.background5:SetPosition(1, 1)
    self.background5:SetHeight(28)
    self.background5.MouseEnter = function ()
        self.contentHover = true
        self.frame3:SetBackColor(Turbine.UI.Color(0.65, 0.54, 0.28))
    end
    self.background5.MouseLeave = function ()
        self.contentHover = false
        self.frame3:SetBackColor(Turbine.UI.Color(0.05, 0.04, 0.03))
    end
    self.background5.MouseDown = function ()
        self.background5:SetBackColor(Turbine.UI.Color(0.18, 0.15, 0.08))
    end
    self.background5.MouseUp = function ()
        self.background5:SetBackColor(Turbine.UI.Color(0.05, 0.04, 0.03))
        if self.contentHover then
            self:UpdateSelection(false, true, false)
        end
    end

    self.content = Turbine.UI.Label()
    self.content:SetParent(self.background5)
    self.content:SetHeight(28)
    self.content:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter)
    self.content:SetFont(Turbine.UI.Lotro.Font.Verdana16)
    self.content:SetText("Content")
    self.content:SetMouseVisible(false)
    self.content:SetFontStyle(Turbine.UI.FontStyle.Outline)
    self.content:SetForeColor(Turbine.UI.Color(0.52, 0.45, 0.32))

    self.frame4 = Turbine.UI.Control()
    self.frame4:SetParent(self.frame1)
    self.frame4:SetBackColor(Turbine.UI.Color(0.05, 0.04, 0.03))
    self.frame4:SetHeight(30)

    self.background6 = Turbine.UI.Control()
    self.background6:SetParent(self.frame4)
    self.background6:SetBackColor(Turbine.UI.Color(0.05, 0.04, 0.03))
    self.background6:SetPosition(1, 1)
    self.background6:SetHeight(28)
    self.background6.MouseEnter = function ()
        self.characterHover = true
        self.frame4:SetBackColor(Turbine.UI.Color(0.65, 0.54, 0.28))
    end
    self.background6.MouseLeave = function ()
        self.characterHover = false
        self.frame4:SetBackColor(Turbine.UI.Color(0.05, 0.04, 0.03))
    end
    self.background6.MouseDown = function ()
        self.background6:SetBackColor(Turbine.UI.Color(0.18, 0.15, 0.08))
    end
    self.background6.MouseUp = function ()
        self.background6:SetBackColor(Turbine.UI.Color(0.05, 0.04, 0.03))
        if self.characterHover then
            self:UpdateSelection(false, false, true)
        end
    end

    self.characters = Turbine.UI.Label()
    self.characters:SetParent(self.background6)
    self.characters:SetHeight(28)
    self.characters:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter)
    self.characters:SetFont(Turbine.UI.Lotro.Font.Verdana16)
    self.characters:SetText("Characters")
    self.characters:SetMouseVisible(false)
    self.characters:SetFontStyle(Turbine.UI.FontStyle.Outline)
    self.characters:SetForeColor(Turbine.UI.Color(0.52, 0.45, 0.32))

    -- filter / collapse row
    self.background2 = Turbine.UI.Control()
    self.background2:SetParent(self.frame1)
    self.background2:SetBackColor(Turbine.UI.Color(0.07, 0.06, 0.04))
    self.background2:SetHeight(20)

    self.filter = Turbine.UI.Lotro.TextBox()
    self.filter:SetParent(self.background2)
    self.filter:SetHeight(20)
    self.filter:SetFont(Turbine.UI.Lotro.Font.Verdana12)
    self.filter:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
    self.filter:SetMultiline(false)
    self.filter:SetForeColor(Turbine.UI.Color(0.52, 0.45, 0.32))
    self.filter:SetText("search ...")

    self.background3 = Turbine.UI.Control()
    self.background3:SetParent(self.frame1)
    self.background3:SetBackColor(Turbine.UI.Color(0.05, 0.04, 0.03))
    self.background3:SetSize(20, 20)
    self.background3.MouseEnter = function ()
        self.collapseHover = true
        self.background3:SetBackColor(Turbine.UI.Color(0.18, 0.15, 0.08))
    end
    self.background3.MouseLeave = function ()
        self.collapseHover = false
        self.background3:SetBackColor(Turbine.UI.Color(0.05, 0.04, 0.03))
    end
    self.background3.MouseDown = function ()
        self.background3:SetBackColor(Turbine.UI.Color(0.25, 0.20, 0.10))
    end
    self.background3.MouseUp = function ()
        if self.collapseHover then
            self.background3:SetBackColor(Turbine.UI.Color(0.18, 0.15, 0.08))
            self:CollapseAll()
        end
    end

    self.collapseAll = Turbine.UI.Label()
    self.collapseAll:SetParent(self.background3)
    self.collapseAll:SetSize(20, 20)
    self.collapseAll:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter)
    self.collapseAll:SetFont(Turbine.UI.Lotro.Font.Verdana16)
    self.collapseAll:SetText("C")
    self.collapseAll:SetMouseVisible(false)
    self.collapseAll:SetFontStyle(Turbine.UI.FontStyle.Outline)
    self.collapseAll:SetForeColor(Turbine.UI.Color(0.52, 0.45, 0.32))

    self.itemView = Turbine.UI.ListBox()
    self.itemView:SetParent(self.frame1)
    self.itemView:SetBackColor(Turbine.UI.Color(0.07, 0.06, 0.04))

    self.itemScrollbar = Turbine.UI.Lotro.ScrollBar()
    self.itemScrollbar:SetOrientation(Turbine.UI.Orientation.Vertical)
    self.itemScrollbar:SetParent(self.itemView)
    self.itemScrollbar:SetWidth(10)
    self.itemView:SetVerticalScrollBar(self.itemScrollbar)

end
