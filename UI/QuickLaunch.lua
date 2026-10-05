
-- Update 49.6: a window can no longer scale its own picture, so a picture that has to follow the
-- Quicklaunch Icon Size setting lives on a child control instead. Only a child control can be
-- given edge attachments, and only a control that has them is stretched to its size. The picture
-- is set first, then stretch mode 2 snaps the control to the picture's own size, then mode 1
-- stretches it to whatever size the control is given afterwards (this is the order Gibberish3 uses).
--
-- A control with edge attachments does not keep the size it was given by itself: a size set while
-- it is hidden is lost, and the size drifts when the window around it is moved. So the size is set
-- again after every move and whenever the window shows up, and checked a few times a second.
local function AttachImageEdges(control)
    -- clients older than 49.6 have no edge attachments and stretch without being asked
    if Turbine.UI.EdgeAttachmentType == nil then return end

    -- Same / Same / Opposite / Opposite pins the control to its own top left and leaves its size alone
    control:AttachEdges(Turbine.UI.EdgeAttachmentType.Same,
                        Turbine.UI.EdgeAttachmentType.Same,
                        Turbine.UI.EdgeAttachmentType.Opposite,
                        Turbine.UI.EdgeAttachmentType.Opposite)
end

local function SetStretchedImage(control, image)
    control:SetBackground(image)
    control:SetStretchMode(2)
    control:SetStretchMode(1)
end

_G.QuickLaunch = class(Turbine.UI.Window)

function _G.QuickLaunch:Constructor()
    Turbine.UI.Window.Constructor(self)

    self:SetSize(50, 50)

    -- the picture: the window only carries the position and the mouse handling
    self.icon = Turbine.UI.Control()
    self.icon:SetParent(self)
    self.icon:SetPosition(0, 0)
    self.icon:SetMouseVisible(false)
    AttachImageEdges(self.icon)
    SetStretchedImage(self.icon, "LootLogs/Ressources/lootlogs_icon.tga")
    self.icon:SetSize(50, 50)
    self.iconSize = 50

    local s = _G.Settings.quickLaunch
    self:SetPosition(s.left, s.top)
    self:SetVisible(true)

    local isDragging = false
    local dragX, dragY = 0, 0
    local badgeCount = 0

    self.badge = Turbine.UI.Window()
    -- self.badge:SetParent(self)
    self.badge:SetSize(20, 20)
    self.badge:SetBackground("LootLogs/Ressources/badge_dot.tga")
    -- self.badge:SetBlendMode(Turbine.UI.BlendMode.Overlay)
    self.badge:SetVisible(false)
    self.badge:SetMouseVisible(false)
    self.badge:SetZOrder(1)

    self.badgeLabel = Turbine.UI.Label()
    self.badgeLabel:SetMultiline(false)
    self.badgeLabel:SetParent(self.badge)
    self.badgeLabel:SetPosition(0, 0)
    self.badgeLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter)
    self.badgeLabel:SetFont(_G.Font(12))
    self.badgeLabel:SetFontStyle(Turbine.UI.FontStyle.Outline)
    self.badgeLabel:SetForeColor(Turbine.UI.Color(1.0, 1.0, 1.0))
    self.badgeLabel:SetMouseVisible(false)
    self.badgeLabel:SetSize(20, 20)

    function self:ApplyIconSize()
        self.icon:SetSize(self.iconSize, self.iconSize)
    end

    function self:SetIconSize(newSize)
        self.iconSize = newSize
        self:SetSize(newSize, newSize)
        self:ApplyIconSize()
        self.badge:SetPosition(s.left + newSize - 15, s.top - 5)
    end

    -- a few times a second: put the picture back to its size if it has drifted
    local nextCheck = 0
    function self:Update()
        local now = Turbine.Engine.GetGameTime()
        if now < nextCheck then return end
        nextCheck = now + 0.25
        local w, h = self.icon:GetSize()
        if w ~= self.iconSize or h ~= self.iconSize then
            self:ApplyIconSize()
        end
    end
    self:SetWantsUpdates(true)

    local setVisible = self.SetVisible
    function self:SetVisible(visible)
        setVisible(self, visible)
        if visible then self:ApplyIconSize() end
    end

    self:SetIconSize(_G.Settings.quickLaunchSize or 50)

    function self:IncrementBadge()
        if not _G.Settings.showBadge then return end
        badgeCount = badgeCount + 1
        self.badgeLabel:SetText(tostring(badgeCount))
        self.badge:SetVisible(true)
    end

    function self:ClearBadge()
        badgeCount = 0
        self.badge:SetVisible(false)
    end

    self.MouseDown = function(sender, args)
        self:ClearBadge()
        if args.Button == Turbine.UI.MouseButton.Right then
            _G.Window:SetVisible(not _G.Window:IsVisible())
        elseif args.Button == Turbine.UI.MouseButton.Left then
            isDragging = true
            dragX = args.X
            dragY = args.Y
        end
    end

    self.MouseMove = function(sender, args)
        if isDragging then
            local x, y = self:GetPosition()
            self:SetPosition(x + args.X - dragX, y + args.Y - dragY)
            self:ApplyIconSize()
        end
    end

    self.MouseUp = function(sender, args)
        if args.Button == Turbine.UI.MouseButton.Left and isDragging then
            isDragging = false
            self:ApplyIconSize()
            local left, top = self:GetPosition()
            _G.Settings.quickLaunch.left = left
            _G.Settings.quickLaunch.top  = top
            _G.SaveSettings()
        end
    end

end
