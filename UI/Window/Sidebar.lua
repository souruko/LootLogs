
import "LootLogsBeta.UI.Window.SidebarItems.CharacterItem"
import "LootLogsBeta.UI.Window.SidebarItems.InstanceItem"

import "LootLogsBeta.UI.Window.SidebarItems.ContentItem"
import "LootLogsBeta.UI.Window.SidebarItems.ServerItem"

Sidebar = class(Turbine.UI.Control)
-- window constructor --------------------------------------------------------------------------
function Sidebar:Constructor()
	Turbine.UI.Control.Constructor( self )

    self:Build()
    self.customListSelected = nil
    self.contentSelected = false
    self.characterSelected = false
    self.selectedContent = nil
    self.selectedInstance = nil

    self.selectedServer = nil
    self.selectedCharacter = nil

    self.customListHover = false
    self.collapseHover = false
    self.contentHover = false
    self.characterHover = false

    self.filterText = ""

    self.characterItems = {}
    self.contenItems = {}
    self.serverItems = {}

    self:CreateInstanceItems()
    self:CreateContentItems()

    self:CreateCharacterItems()
    self:CreateServerItems()

    self:ApplySettings()

    local contentSelected = _G.Settings.selected.tab == _G.Tab.Content
    local characterSelected = _G.Settings.selected.tab == _G.Tab.Characters
    self:UpdateSelection(_G.Settings.selected.customList, contentSelected, characterSelected)

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

    local contentIndices = {}
    for contentIndex in pairs(_G.Content) do
        table.insert(contentIndices, contentIndex)
    end
    table.sort(contentIndices, function(a, b) return a > b end)

    for _, contentIndex in ipairs(contentIndices) do
        local index = #self.contenItems+1
        self.contenItems[index] = SidebarItems.ContentItem(_G.Content[contentIndex], contentIndex, self)
    end

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

    local text = self.filterText or ""

    for _, contentItem in pairs(self.contenItems) do
        contentItem.searchText = text

        local matching = {}
        for _, instanceItem in pairs(self.instanceItems) do
            if instanceItem.instance.content == contentItem.index then
                table.insert(matching, instanceItem)
            end
        end
        table.sort(matching, function(a, b) return a.id > b.id end)

        for _, instanceItem in ipairs(matching) do
            contentItem:AddChild(instanceItem)
        end

        contentItem:FillChildren()
        if text == "" or contentItem:GetItemCount() > 1 then
            self.itemView:AddItem(contentItem)
        end
    end

end

function Sidebar:FillCharacterItems()

    self.itemView:ClearItems()
    for _, item in pairs(self.serverItems) do
        item:ClearChildren()
    end

    local text = self.filterText or ""

    if _G.Settings.showServers then
        for index = 1, #self.serverItems - 1 do
            local serverItem = self.serverItems[index]
            serverItem.searchText = text
            for cIndex, characterItem in pairs(self.characterItems) do
                if characterItem.character.server == serverItem.name then
                    serverItem:AddChild(characterItem)
                end
            end
            serverItem:FillChildren()
            if text == "" or serverItem:GetItemCount() > 1 then
                self.itemView:AddItem(serverItem)
            end
        end
        local noServerItem = self.serverItems[#self.serverItems]
        noServerItem.searchText = text
        for index, characterItem in pairs(self.characterItems) do
            if characterItem.character.server == nil then
                noServerItem:AddChild(characterItem)
            end
        end
        noServerItem:FillChildren()
        if noServerItem:GetItemCount() > 1 then
            self.itemView:AddItem(noServerItem)
        end

    else
        local lowerText = string.lower(text)
        for index, item in pairs(self.characterItems) do
            if text == "" or string.find(string.lower(item.character.name), lowerText, 1, true) then
                self.itemView:AddItem(item)
            end
        end

    end

end

function Sidebar:RefreshItems()

    self:CreateServerItems()
    self:CreateCharacterItems()

    local itemWidth = self:GetWidth() - 22
    for _, item in pairs(self.serverItems) do
        item:SetWidth(itemWidth)
    end
    for _, item in pairs(self.characterItems) do
        item:SetWidth(itemWidth)
    end

    if self.characterSelected then
        self:FillCharacterItems()
    elseif self.contentSelected then
        self:FillContentItems()
    end

end

function Sidebar:ClearSelection()

    self:CreateServerItems()
    self:CreateCharacterItems()

    local itemWidth = self:GetWidth() - 22
    for _, item in pairs(self.serverItems) do
        item:SetWidth(itemWidth)
    end
    for _, item in pairs(self.characterItems) do
        item:SetWidth(itemWidth)
    end

    self.selectedCharacter = nil
    self.selectedServer    = nil

    if self.characterSelected then
        self:FillCharacterItems()
    elseif self.contentSelected then
        self:FillContentItems()
    end

    self:UpdateSelectionVisual()

end

function Sidebar:ApplyFilter(text)

    self.filterText = text

    if self.contentSelected then
        self:FillContentItems()
    elseif self.characterSelected then
        self:FillCharacterItems()
    end

end

function Sidebar:UpdateSelection(isCustomList, isContent, isCharacter)

    if isCustomList then
        local wasContent   = self.contentSelected
        local wasCharacter = self.characterSelected
        self.customListSelected = true
        self.contentSelected = false
        self.characterSelected = false
        _G.Settings.selected.customList = true
        _G.SaveSettings()
        -- custom list has no sidebar items of its own; fill based on last tab
        if not wasContent and not wasCharacter then
            if _G.Settings.selected.tab == _G.Tab.Content then
                self:FillContentItems()
            else
                self:FillCharacterItems()
            end
        end

    elseif isContent then
        if self.contentSelected == false then
            self:FillContentItems()
        end

        self.customListSelected = false
        self.contentSelected = true
        self.characterSelected = false
        _G.Settings.selected.tab = _G.Tab.Content
        _G.Settings.selected.customList = false

    elseif isCharacter then
        if self.characterSelected == false then
            self:FillCharacterItems()
        end

        self.customListSelected = false
        self.contentSelected = false
        self.characterSelected = true
        _G.Settings.selected.tab = _G.Tab.Characters
        _G.Settings.selected.customList = false
    end

    self:UpdateSelectionVisual()

    if (isCustomList or isContent or isCharacter) and self:GetParent() ~= nil then
        self:GetParent():SelectionChanged()
    end

end

function Sidebar:UpdateSelectionVisual()

    if self.customListSelected then
        self.background4:SetBackColor(_G.Theme.SEL_BG)
        self.customList:SetForeColor(_G.Theme.ACCENT)
    else
        self.background4:SetBackColor(_G.Theme.BG)
        self.customList:SetForeColor(_G.Theme.DIM2)
    end

    local contentDim   = self.customListSelected and _G.Settings.selected.tab == _G.Tab.Content
    local characterDim = self.customListSelected and _G.Settings.selected.tab == _G.Tab.Characters

    if self.contentSelected then
        self.background5:SetBackColor(_G.Theme.SEL_BG)
        self.content:SetForeColor(_G.Theme.ACCENT)
    elseif contentDim then
        self.background5:SetBackColor(_G.Theme.HEADER)
        self.content:SetForeColor(_G.Theme.HOVER)
    else
        self.background5:SetBackColor(_G.Theme.BG)
        self.content:SetForeColor(_G.Theme.DIM2)
    end

    if self.characterSelected then
        self.background6:SetBackColor(_G.Theme.SEL_BG)
        self.characters:SetForeColor(_G.Theme.ACCENT)
    elseif characterDim then
        self.background6:SetBackColor(_G.Theme.HEADER)
        self.characters:SetForeColor(_G.Theme.HOVER)
    else
        self.background6:SetBackColor(_G.Theme.BG)
        self.characters:SetForeColor(_G.Theme.DIM2)
    end

end

function Sidebar:CollapseAll()

    if self.characterSelected then
        for index, item in ipairs(self.serverItems) do
            item:SetCollapsed(true)
        end
    elseif self.contentSelected then
        for index, item in ipairs(self.contenItems) do
            item:SetCollapsed(true)
        end
    end

end

function Sidebar:SizeChanged()

    local width, height = self:GetSize()

    self.background1:SetSize(width - 10, height - 10)
    self.frame1:SetSize(width - 20, height - 20)

    -- todo
    self.frame2:SetWidth(width - 22)
    self.background4:SetWidth(width - 24)
    self.customList:SetWidth(width - 22)

    -- content / character toggle
    self.frame3:SetWidth(math.floor((width - 22) / 2))
    self.background5:SetWidth(math.floor((width - 22) / 2) - 2)
    self.content:SetWidth(self.background5:GetWidth())

    self.frame4:SetLeft(self.background5:GetWidth() + 4)
    self.frame4:SetWidth(width - self.frame4:GetLeft() - 21)
    self.background6:SetWidth(self.frame4:GetWidth() - 2)
    self.characters:SetWidth(self.background6:GetWidth())

    -- filter
    self.background2:SetWidth(width - 64)
    self.filter:SetWidth(width - 64)

    -- clear button
    self.clearBg:SetLeft(width - 62)

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
    if _G.Settings.showCustomList == true then

        self.frame2:SetPosition(1, top)
        self.frame2:SetVisible(true)
        self.background4:SetVisible(true)
        self.customList:SetVisible(true)
        top = top + 31

    else

        self.frame2:SetVisible(false)
        self.background4:SetVisible(false)
        self.customList:SetVisible(false)

    end

    -- content / character toggle
    self.frame3:SetPosition(1, top)
    self.frame4:SetTop(top)

    top = top + 31

    -- filter
    self.background2:SetPosition(1, top)

    -- clear button
    self.clearBg:SetTop(top)

    -- collapse button
    self.background3:SetTop(top)
    top = top + 21

    -- select
    self.itemView:SetPosition(1, top)

    self:SizeChanged()

end

function Sidebar:ApplyLanguage()

    self.customList:SetText(_G.L("customListBtn"))
    self.content:SetText(_G.L("contentBtn"))
    self.characters:SetText(_G.L("charactersBtn"))

    if self.filterText == "" then
        self.filter:SetText(_G.L("searchPlaceholder"))
    end

end

function Sidebar:Build()

    -- base background: warm dark brown outer ring
	self:SetBackColor(_G.Theme.OUTER)

    self.background1 = Turbine.UI.Control()
    self.background1:SetParent(self)
    self.background1:SetBackColor(_G.Theme.BG)
    self.background1:SetPosition(5, 5)

    self.frame1 = Turbine.UI.Control()
    self.frame1:SetParent(self.background1)
    self.frame1:SetBackColor(_G.Theme.FRAME)
    self.frame1:SetPosition(5, 5)

    -- todo row
    self.frame2 = Turbine.UI.Control()
    self.frame2:SetParent(self.frame1)
    self.frame2:SetBackColor(_G.Theme.BG)
    self.frame2:SetHeight(30)

    self.background4 = Turbine.UI.Control()
    self.background4:SetParent(self.frame2)
    self.background4:SetBackColor(_G.Theme.BG)
    self.background4:SetPosition(1, 1)
    self.background4:SetHeight(28)
    self.background4.MouseEnter = function ()
        self.customListHover = true
        self.frame2:SetBackColor(_G.Theme.HOVER)
    end
    self.background4.MouseLeave = function ()
        self.customListHover = false
        self.frame2:SetBackColor(_G.Theme.BG)
    end
    self.background4.MouseDown = function ()
        self.background4:SetBackColor(_G.Theme.PRESS)
    end
    self.background4.MouseUp = function ()
        self.background4:SetBackColor(_G.Theme.BG)
        if self.customListHover then
            self:UpdateSelection(true, false, false)
        end
    end

    self.customList = Turbine.UI.Label()
    self.customList:SetParent(self.background4)
    self.customList:SetHeight(28)
    self.customList:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter)
    self.customList:SetFont(Turbine.UI.Lotro.Font.Verdana16)
    self.customList:SetFontStyle(_G.Theme.FONT_STYLE)
    self.customList:SetText(_G.L("customListBtn"))
    self.customList:SetMouseVisible(false)
    self.customList:SetForeColor(_G.Theme.DIM2)

    -- content / characters row
    self.frame3 = Turbine.UI.Control()
    self.frame3:SetParent(self.frame1)
    self.frame3:SetBackColor(_G.Theme.BG)
    self.frame3:SetHeight(30)

    self.background5 = Turbine.UI.Control()
    self.background5:SetParent(self.frame3)
    self.background5:SetBackColor(_G.Theme.BG)
    self.background5:SetPosition(1, 1)
    self.background5:SetHeight(28)
    self.background5.MouseEnter = function ()
        self.contentHover = true
        self.frame3:SetBackColor(_G.Theme.HOVER)
    end
    self.background5.MouseLeave = function ()
        self.contentHover = false
        self.frame3:SetBackColor(_G.Theme.BG)
    end
    self.background5.MouseDown = function ()
        self.background5:SetBackColor(_G.Theme.PRESS)
    end
    self.background5.MouseUp = function ()
        self.background5:SetBackColor(_G.Theme.BG)
        if self.contentHover then
            self:UpdateSelection(false, true, false)
        end
    end

    self.content = Turbine.UI.Label()
    self.content:SetParent(self.background5)
    self.content:SetHeight(28)
    self.content:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter)
    self.content:SetFont(Turbine.UI.Lotro.Font.Verdana16)
    self.content:SetText(_G.L("contentBtn"))
    self.content:SetMouseVisible(false)
    self.content:SetFontStyle(_G.Theme.FONT_STYLE)
    self.content:SetForeColor(_G.Theme.DIM2)

    self.frame4 = Turbine.UI.Control()
    self.frame4:SetParent(self.frame1)
    self.frame4:SetBackColor(_G.Theme.BG)
    self.frame4:SetHeight(30)

    self.background6 = Turbine.UI.Control()
    self.background6:SetParent(self.frame4)
    self.background6:SetBackColor(_G.Theme.BG)
    self.background6:SetPosition(1, 1)
    self.background6:SetHeight(28)
    self.background6.MouseEnter = function ()
        self.characterHover = true
        self.frame4:SetBackColor(_G.Theme.HOVER)
    end
    self.background6.MouseLeave = function ()
        self.characterHover = false
        self.frame4:SetBackColor(_G.Theme.BG)
    end
    self.background6.MouseDown = function ()
        self.background6:SetBackColor(_G.Theme.PRESS)
    end
    self.background6.MouseUp = function ()
        self.background6:SetBackColor(_G.Theme.BG)
        if self.characterHover then
            self:UpdateSelection(false, false, true)
        end
    end

    self.characters = Turbine.UI.Label()
    self.characters:SetParent(self.background6)
    self.characters:SetHeight(28)
    self.characters:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter)
    self.characters:SetFont(Turbine.UI.Lotro.Font.Verdana16)
    self.characters:SetText(_G.L("charactersBtn"))
    self.characters:SetMouseVisible(false)
    self.characters:SetFontStyle(_G.Theme.FONT_STYLE)
    self.characters:SetForeColor(_G.Theme.DIM2)

    -- filter / collapse row
    self.background2 = Turbine.UI.Control()
    self.background2:SetParent(self.frame1)
    self.background2:SetBackColor(_G.Theme.PANEL)
    self.background2:SetHeight(20)

    self.filter = Turbine.UI.TextBox()
    self.filter:SetParent(self.background2)
    self.filter:SetHeight(20)
    self.filter:SetFont(Turbine.UI.Lotro.Font.Verdana12)
    self.filter:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
    self.filter:SetMultiline(false)
    self.filter:SetBackColor(_G.Theme.PANEL)
    self.filter:SetForeColor(_G.Theme.DIM2)
    self.filter:SetText(_G.L("searchPlaceholder"))
    self.filter.FocusGained = function()
        if self.filter:GetText() == _G.L("searchPlaceholder") then
            self.filter:SetText("")
        end
    end
    self.filter.FocusLost = function()
        if self.filter:GetText() == "" then
            self.filter:SetText(_G.L("searchPlaceholder"))
            self:ApplyFilter("")
        end
    end
    self.filter.TextChanged = function()
        local text = self.filter:GetText()
        if text == _G.L("searchPlaceholder") then text = "" end
        self:ApplyFilter(text)
    end

    -- clear search button
    self.clearBg = Turbine.UI.Control()
    self.clearBg:SetParent(self.frame1)
    self.clearBg:SetSize(20, 20)
    self.clearBg:SetBackColor(_G.Theme.PANEL)

    local clearHover = false
    self.clearBg.MouseEnter = function()
        clearHover = true
        self.clearBg:SetBackColor(_G.Theme.PRESS)
        self.clearLabel:SetForeColor(_G.Theme.TEXT)
    end
    self.clearBg.MouseLeave = function()
        clearHover = false
        self.clearBg:SetBackColor(_G.Theme.PANEL)
        self.clearLabel:SetForeColor(_G.Theme.DIM2)
    end
    self.clearBg.MouseDown = function()
        self.clearBg:SetBackColor(_G.Theme.SEL_BG)
    end
    self.clearBg.MouseUp = function()
        self.clearBg:SetBackColor(_G.Theme.PANEL)
        if clearHover then
            self.filter:SetText(_G.L("searchPlaceholder"))
            self:ApplyFilter("")
        end
    end

    self.clearLabel = Turbine.UI.Label()
    self.clearLabel:SetParent(self.clearBg)
    self.clearLabel:SetSize(20, 20)
    self.clearLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter)
    self.clearLabel:SetFont(Turbine.UI.Lotro.Font.Verdana16)
    self.clearLabel:SetFontStyle(_G.Theme.FONT_STYLE)
    self.clearLabel:SetText("X")
    self.clearLabel:SetMouseVisible(false)
    self.clearLabel:SetForeColor(_G.Theme.DIM2)

    self.background3 = Turbine.UI.Control()
    self.background3:SetParent(self.frame1)
    self.background3:SetBackColor(_G.Theme.BG)
    self.background3:SetBackground("LootLogsBeta/Ressources/collaps.tga")
    self.background3:SetBlendMode(Turbine.UI.BlendMode.Multiplys)
    self.background3:SetSize(20, 20)
    self.background3.MouseEnter = function ()
        self.collapseHover = true
        self.background3:SetBackColor(_G.Theme.PRESS)
    end
    self.background3.MouseLeave = function ()
        self.collapseHover = false
        self.background3:SetBackColor(_G.Theme.BG)
    end
    self.background3.MouseDown = function ()
        self.background3:SetBackColor(_G.Theme.SEL_BG)
    end
    self.background3.MouseUp = function ()
        if self.collapseHover then
            self.background3:SetBackColor(_G.Theme.PRESS)
            self:CollapseAll()
        end
    end

    self.collapsIcon = Turbine.UI.Control()
    self.collapsIcon:SetParent(self.background3)
    self.collapsIcon:SetBackground("LootLogsBeta/Ressources/collaps.tga")
    self.collapsIcon:SetBlendMode(Turbine.UI.BlendMode.Overlay)
    self.collapsIcon:SetPosition(-2, -2)
    self.collapsIcon:SetSize(20, 20)
    self.collapsIcon:SetMouseVisible(false)

    self.itemView = Turbine.UI.ListBox()
    self.itemView:SetParent(self.frame1)
    self.itemView:SetBackColor(_G.Theme.PANEL)

    self.itemScrollbar = Turbine.UI.Lotro.ScrollBar()
    self.itemScrollbar:SetOrientation(Turbine.UI.Orientation.Vertical)
    self.itemScrollbar:SetParent(self.itemView)
    self.itemScrollbar:SetWidth(10)
    self.itemView:SetVerticalScrollBar(self.itemScrollbar)

end
