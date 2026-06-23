
_G.QuickLaunch = class(Turbine.UI.Window)

function _G.QuickLaunch:Constructor()
    Turbine.UI.Window.Constructor(self)

    self:SetSize(50, 50)
    self:SetBackground("LootLogsBeta/Ressources/lootlogs_icon.tga")

    local s = _G.Settings.quickLaunch
    self:SetPosition(s.left, s.top)
    self:SetVisible(true)

    local isDragging = false
    local dragX, dragY = 0, 0
    local badgeCount = 0

    self.badge = Turbine.UI.Window()
    self.badge:SetParent(self)
    self.badge:SetSize(20, 20)
    self.badge:SetPosition(30, 0)
    self.badge:SetBackground("LootLogsBeta/Ressources/badge_dot.tga")
    -- self.badge:SetBlendMode(Turbine.UI.BlendMode.Overlay)
    self.badge:SetVisible(false)
    self.badge:SetMouseVisible(false)

    self.badgeLabel = Turbine.UI.Label()
    self.badgeLabel:SetParent(self.badge)
    self.badgeLabel:SetSize(20, 20)
    self.badgeLabel:SetPosition(0, 0)
    self.badgeLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter)
    self.badgeLabel:SetFont(Turbine.UI.Lotro.Font.Verdana14)
    self.badgeLabel:SetFontStyle(Turbine.UI.FontStyle.Outline)
    self.badgeLabel:SetForeColor(Turbine.UI.Color(1.0, 1.0, 1.0))
    self.badgeLabel:SetMouseVisible(false)

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
        end
    end

    self.MouseUp = function(sender, args)
        if args.Button == Turbine.UI.MouseButton.Left and isDragging then
            isDragging = false
            local left, top = self:GetPosition()
            _G.Settings.quickLaunch.left = left
            _G.Settings.quickLaunch.top  = top
            _G.SaveSettings()
        end
    end

end
