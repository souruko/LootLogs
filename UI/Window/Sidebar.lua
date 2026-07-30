
import "LootLogs.UI.Window.SidebarItems.CharacterItem"
import "LootLogs.UI.Window.SidebarItems.InstanceItem"

import "LootLogs.UI.Window.SidebarItems.ContentItem"
import "LootLogs.UI.Window.SidebarItems.ServerItem"

-- sidebar geometry (docs/design/window-redesign/README.md, section 2)
local BORDER     = 1
local TAB_PAD    = 4
local TAB_H      = 28
local TAB_GAP    = 2
-- the handoff says 62, which assumed an inline text star; a real 16px icon needs more
local PINNED_W   = 76
local PAD        = 8
local SEARCH_H   = 24
local ICON       = 16
local COLLAPSE_W = 78
local SEARCH_TOP = TAB_PAD + TAB_H + TAB_PAD
local LIST_TOP   = SEARCH_TOP + SEARCH_H + TAB_PAD

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

    self.collapseHover = false

    self.filterText    = ""
    self.filterFocused = false

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

-- the window, which is no longer our direct parent: PanelWindow puts content
-- inside self.client and hangs a back-pointer off it
function Sidebar:Window()

    local parent = self:GetParent()
    return parent ~= nil and parent.window or nil

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

    self:Window():SelectionChanged()

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

    self:Window():SelectionChanged()

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

    self:Window():SelectionChanged()

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

    self:Window():SelectionChanged()

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
    self.serverItems[index] = SidebarItems.ServerItem("No Server Selected", self, _G.L("noServer"))

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

    self:RefreshTierSquares()

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
        local sorted = {}
        for _, item in pairs(self.characterItems) do
            if text == "" or string.find(string.lower(item.character.name), lowerText, 1, true) then
                table.insert(sorted, item)
            end
        end
        table.sort(sorted, function(a, b)
            local aLevel = a.character and a.character.level or 0
            local bLevel = b.character and b.character.level or 0
            if aLevel ~= bLevel then return aLevel > bLevel end
            return string.lower(a.name) < string.lower(b.name)
        end)
        for _, item in ipairs(sorted) do
            self.itemView:AddItem(item)
        end

    end

end

-- the per-tier squares are derived from the logs at render time, so they have to be
-- recomputed whenever the logs change or the list is rebuilt
function Sidebar:RefreshTierSquares()

    for _, item in pairs(self.instanceItems or {}) do
        item:RefreshSquares()
    end

end

function Sidebar:RefreshItems()

    self:CreateServerItems()
    self:CreateCharacterItems()

    local itemWidth = self:ItemWidth()
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

    local itemWidth = self:ItemWidth()
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

    if (isCustomList or isContent or isCharacter) and self:Window() ~= nil then
        self:Window():SelectionChanged()
    end

end
function Sidebar:UpdateSelectionVisual()

    -- while the Pinned tab is selected the list still shows one of the other two
    -- tabs, so that tab is marked as well, a step below selected
    local showingContent    = _G.Settings.selected.tab == _G.Tab.Content
    local showingCharacters = _G.Settings.selected.tab == _G.Tab.Characters

    self.pinnedTab.selected     = self.customListSelected == true
    self.contentTab.selected    = self.contentSelected == true
    self.charactersTab.selected = self.characterSelected == true

    self.pinnedTab.dimmed     = false
    self.contentTab.dimmed    = self.customListSelected and showingContent
    self.charactersTab.dimmed = self.customListSelected and showingCharacters

    self.pinnedTab:ApplyState()
    self.contentTab:ApplyState()
    self.charactersTab:ApplyState()

end

function Sidebar:CollapseAll()

    local showingCharacters = self.characterSelected or
                              (self.customListSelected and _G.Settings.selected.tab == _G.Tab.Characters)
    local showingContent    = self.contentSelected or
                              (self.customListSelected and _G.Settings.selected.tab == _G.Tab.Content)

    if showingCharacters then
        for index, item in ipairs(self.serverItems or {}) do
            item:SetCollapsed(true)
        end
    elseif showingContent then
        for index, item in ipairs(self.contenItems or {}) do
            item:SetCollapsed(true)
        end
    end

end

-- ------------------------------------------------------------------------------------------------

function Sidebar:ClearFilter()

    self.filter:SetText("")
    self:ApplyFilter("")
    self:RefreshSearchRow()

end

-- the clear button only exists while there is something to clear
function Sidebar:RefreshSearchRow()

    local filtering = (self.filterText or "") ~= ""

    self.clearBtn:SetVisible(filtering)
    self.placeholder:SetVisible(not filtering and not self.filterFocused)
    self:LayoutSearchRow()

end

function Sidebar:LayoutSearchRow()

    local inner = self.searchBg:GetWidth()
    if inner <= 0 then return end

    local collapseLeft = inner - COLLAPSE_W
    self.collapseBtn:SetPosition(collapseLeft, 0)
    self.collapseBtn:SetSize(COLLAPSE_W, SEARCH_H - 2 * BORDER)
    self.collapseLabel:SetWidth(math.max(0, COLLAPSE_W - ICON - 4))
    self.collapseIcon:SetLeft(COLLAPSE_W - ICON - 2)

    local clearLeft = collapseLeft - 2 - ICON
    self.clearBtn:SetPosition(clearLeft, math.floor((SEARCH_H - 2 * BORDER - ICON) / 2))

    local textLeft  = ICON + 6
    local textRight = self.clearBtn:IsVisible() and clearLeft or collapseLeft
    local textWidth = math.max(0, textRight - textLeft - 2)

    self.filter:SetPosition(textLeft, 1)
    self.filter:SetWidth(textWidth)
    self.placeholder:SetPosition(textLeft + 2, 0)
    self.placeholder:SetWidth(textWidth)

end

function Sidebar:ItemWidth()

    return math.max(0, self:GetWidth() - 2 * BORDER - 12)

end

function Sidebar:SizeChanged()

    if self.panel == nil then return end

    local width, height = self:GetSize()
    local iw = math.max(0, width  - 2 * BORDER)
    local ih = math.max(0, height - 2 * BORDER)

    self.panel:SetSize(iw, ih)

    -- tab row ---------------------------------------------------------------------------------
    local rowWidth = iw - 2 * TAB_PAD
    local pinnedW  = self.pinnedTab:IsVisible() and PINNED_W or 0
    local gapCount = pinnedW > 0 and 2 or 1
    local rest     = math.max(0, rowWidth - pinnedW - TAB_GAP * gapCount)
    local contentW = math.floor(rest / 2)
    local charW    = rest - contentW

    self.contentTab:SetPosition(TAB_PAD, TAB_PAD)
    self.contentTab:SetWidth(contentW)
    self.contentTab.label:SetWidth(contentW)

    self.charactersTab:SetPosition(TAB_PAD + contentW + TAB_GAP, TAB_PAD)
    self.charactersTab:SetWidth(charW)
    self.charactersTab.label:SetWidth(charW)

    self.pinnedTab:SetPosition(TAB_PAD + contentW + TAB_GAP + charW + TAB_GAP, TAB_PAD)
    self.pinnedTab:SetWidth(pinnedW)
    self.pinnedTab.label:SetWidth(math.max(0, pinnedW - ICON - 10))

    -- search row ------------------------------------------------------------------------------
    local searchW = iw - 2 * PAD

    self.searchFrame:SetPosition(PAD, SEARCH_TOP)
    self.searchFrame:SetSize(searchW, SEARCH_H)
    self.searchBg:SetSize(math.max(0, searchW - 2 * BORDER), SEARCH_H - 2 * BORDER)
    self:LayoutSearchRow()

    -- list ------------------------------------------------------------------------------------
    self.itemView:SetPosition(0, LIST_TOP)
    self.itemView:SetSize(iw, math.max(0, ih - LIST_TOP))
    self.itemScrollbar:SetHeight(self.itemView:GetHeight())
    self.itemScrollbar:SetLeft(iw - 10)

    local itemWidth = self:ItemWidth()
    for index, item in pairs(self.characterItems or {}) do
        item:SetWidth(itemWidth)
    end
    for index, item in pairs(self.instanceItems or {}) do
        item:SetWidth(itemWidth)
    end
    for index, item in pairs(self.serverItems or {}) do
        item:SetWidth(itemWidth)
    end
    for index, item in pairs(self.contenItems or {}) do
        item:SetWidth(itemWidth)
    end

end

function Sidebar:ApplySettings()

    self.pinnedTab:SetVisible(_G.Settings.showCustomList == true)
    self:SizeChanged()

end

function Sidebar:ApplyLanguage()

    self.pinnedTab.label:SetText(_G.L("pinnedBtn"))
    self.contentTab.label:SetText(_G.L("contentBtn"))
    self.charactersTab.label:SetText(_G.L("charactersBtn"))
    self.placeholder:SetText(_G.L("searchPlaceholder"))
    self.collapseLabel:SetText(_G.L("collapseAll"))

end

-- ------------------------------------------------------------------------------------------------

-- one tab in the top row. iconPath is optional and sits at the left edge.
function Sidebar:MakeTab(iconPath, onClick)

    local tab = Turbine.UI.Control()
    tab:SetParent(self.panel)
    tab:SetHeight(TAB_H)
    tab:SetMouseVisible(true)

    local label = Turbine.UI.Label()
    label:SetMultiline(false)
    label:SetParent(tab)
    label:SetHeight(TAB_H)
    label:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter)
    label:SetFont(Turbine.UI.Lotro.Font.Verdana12)
    label:SetFontStyle(_G.Theme.FONT_STYLE)
    label:SetMouseVisible(false)

    if iconPath ~= nil then
        local icon = Turbine.UI.Control()
        icon:SetParent(tab)
        icon:SetSize(ICON, ICON)
        icon:SetPosition(6, math.floor((TAB_H - ICON) / 2))
        icon:SetBackground(iconPath)
        icon:SetBlendMode(Turbine.UI.BlendMode.Overlay)
        icon:SetMouseVisible(false)
        label:SetPosition(ICON + 8, 0)
        label:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
        tab.icon = icon
    end

    tab.label    = label
    tab.selected = false
    tab.dimmed   = false
    tab.hovered  = false

    function tab:ApplyState()
        if self.selected then
            self:SetBackColor(_G.Theme.SEL_BG)
            self.label:SetForeColor(_G.Theme.ACCENT)
        elseif self.hovered then
            self:SetBackColor(_G.Theme.FRAME)
            self.label:SetForeColor(_G.Theme.TEXT)
        elseif self.dimmed then
            self:SetBackColor(_G.Theme.SECTION)
            self.label:SetForeColor(_G.Theme.TEXT)
        else
            self:SetBackColor(_G.Theme.SECTION)
            self.label:SetForeColor(_G.Theme.DIM2)
        end
    end

    tab.MouseEnter = function() tab.hovered = true  tab:ApplyState() end
    tab.MouseLeave = function() tab.hovered = false tab:ApplyState() end
    tab.MouseClick = onClick
    tab:ApplyState()

    return tab

end

function Sidebar:Build()

    -- 1px border, sunken panel inside it
    self:SetBackColor(_G.Theme.FRAME)

    self.panel = Turbine.UI.Control()
    self.panel:SetParent(self)
    self.panel:SetPosition(BORDER, BORDER)
    self.panel:SetBackColor(_G.Theme.PANEL)

    -- tab row: Content | Characters | Pinned ----------------------------------------------------
    self.contentTab = self:MakeTab(nil, function()
        self:UpdateSelection(false, true, false)
    end)
    self.contentTab.label:SetText(_G.L("contentBtn"))

    self.charactersTab = self:MakeTab(nil, function()
        self:UpdateSelection(false, false, true)
    end)
    self.charactersTab.label:SetText(_G.L("charactersBtn"))

    self.pinnedTab = self:MakeTab("LootLogs/Ressources/star_fill.tga", function()
        self:UpdateSelection(true, false, false)
    end)
    self.pinnedTab.label:SetText(_G.L("pinnedBtn"))

    -- search row --------------------------------------------------------------------------------
    self.searchFrame = Turbine.UI.Control()
    self.searchFrame:SetParent(self.panel)
    self.searchFrame:SetBackColor(_G.Theme.FRAME)

    self.searchBg = Turbine.UI.Control()
    self.searchBg:SetParent(self.searchFrame)
    self.searchBg:SetPosition(BORDER, BORDER)
    self.searchBg:SetBackColor(_G.Theme.BG)

    self.searchIcon = Turbine.UI.Control()
    self.searchIcon:SetParent(self.searchBg)
    self.searchIcon:SetSize(ICON, ICON)
    self.searchIcon:SetPosition(3, math.floor((SEARCH_H - 2 * BORDER - ICON) / 2))
    self.searchIcon:SetBackground("LootLogs/Ressources/search.tga")
    self.searchIcon:SetBlendMode(Turbine.UI.BlendMode.Overlay)
    self.searchIcon:SetMouseVisible(false)

    self.filter = Turbine.UI.TextBox()
    self.filter:SetParent(self.searchBg)
    self.filter:SetHeight(SEARCH_H - 2 * BORDER - 2)
    self.filter:SetFont(Turbine.UI.Lotro.Font.Verdana12)
    self.filter:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
    self.filter:SetMultiline(false)
    self.filter:SetBackColor(_G.Theme.BG)
    self.filter:SetForeColor(_G.Theme.TEXT)
    self.filter:SetText("")

    -- a real placeholder rather than seeding the field with its own prompt text,
    -- which the old sidebar then had to filter back out of every search
    self.placeholder = Turbine.UI.Label()
    self.placeholder:SetMultiline(false)
    self.placeholder:SetParent(self.searchBg)
    self.placeholder:SetHeight(SEARCH_H - 2 * BORDER)
    self.placeholder:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
    self.placeholder:SetFont(Turbine.UI.Lotro.Font.Verdana12)
    self.placeholder:SetFontStyle(_G.Theme.FONT_STYLE)
    self.placeholder:SetForeColor(_G.Theme.DIM)
    self.placeholder:SetText(_G.L("searchPlaceholder"))
    self.placeholder:SetMouseVisible(false)

    self.filter.FocusGained = function()
        self.filterFocused = true
        self:RefreshSearchRow()
    end
    self.filter.FocusLost = function()
        self.filterFocused = false
        self:RefreshSearchRow()
    end
    self.filter.TextChanged = function()
        self:ApplyFilter(self.filter:GetText())
        self:RefreshSearchRow()
    end

    -- clear button, only while there is text
    self.clearBtn = Turbine.UI.Control()
    self.clearBtn:SetParent(self.searchBg)
    self.clearBtn:SetSize(ICON, ICON)
    self.clearBtn:SetBackground("LootLogs/Ressources/cross.tga")
    self.clearBtn:SetBlendMode(Turbine.UI.BlendMode.Overlay)
    self.clearBtn:SetVisible(false)
    self.clearBtn.MouseClick = function()
        self:ClearFilter()
    end

    -- collapse all, at the right edge of the same field
    self.collapseBtn = Turbine.UI.Control()
    self.collapseBtn:SetParent(self.searchBg)
    self.collapseBtn:SetMouseVisible(true)

    self.collapseLabel = Turbine.UI.Label()
    self.collapseLabel:SetMultiline(false)
    self.collapseLabel:SetParent(self.collapseBtn)
    self.collapseLabel:SetPosition(0, 0)
    self.collapseLabel:SetHeight(SEARCH_H - 2 * BORDER)
    self.collapseLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleRight)
    self.collapseLabel:SetFont(Turbine.UI.Lotro.Font.Verdana10)
    self.collapseLabel:SetFontStyle(_G.Theme.FONT_STYLE)
    self.collapseLabel:SetForeColor(_G.Theme.DIM)
    self.collapseLabel:SetText(_G.L("collapseAll"))
    self.collapseLabel:SetMouseVisible(false)

    self.collapseIcon = Turbine.UI.Control()
    self.collapseIcon:SetParent(self.collapseBtn)
    self.collapseIcon:SetSize(ICON, ICON)
    self.collapseIcon:SetTop(math.floor((SEARCH_H - 2 * BORDER - ICON) / 2))
    self.collapseIcon:SetBackground("LootLogs/Ressources/collaps.tga")
    self.collapseIcon:SetBlendMode(Turbine.UI.BlendMode.Overlay)
    self.collapseIcon:SetMouseVisible(false)

    self.collapseBtn.MouseEnter = function()
        self.collapseHover = true
        self.collapseLabel:SetForeColor(_G.Theme.TEXT)
    end
    self.collapseBtn.MouseLeave = function()
        self.collapseHover = false
        self.collapseLabel:SetForeColor(_G.Theme.DIM)
    end
    self.collapseBtn.MouseClick = function()
        self:CollapseAll()
    end

    -- list --------------------------------------------------------------------------------------
    self.itemView = Turbine.UI.ListBox()
    self.itemView:SetParent(self.panel)
    self.itemView:SetBackColor(_G.Theme.PANEL)

    self.itemScrollbar = Turbine.UI.Lotro.ScrollBar()
    self.itemScrollbar:SetOrientation(Turbine.UI.Orientation.Vertical)
    self.itemScrollbar:SetParent(self.itemView)
    self.itemScrollbar:SetWidth(10)
    self.itemView:SetVerticalScrollBar(self.itemScrollbar)

end
