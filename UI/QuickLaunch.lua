
_G.QuickLaunch = class(Turbine.UI.Window)

function _G.QuickLaunch:Constructor()
    Turbine.UI.Window.Constructor(self)

    self:SetSize(50, 50)
    self:SetBackground("LootLogs2/Ressources/lootlogs_icon.tga")

    local s = _G.Settings.quickLaunch
    self:SetPosition(s.left, s.top)
    self:SetVisible(true)

    local isDragging = false
    local dragX, dragY = 0, 0

    self.MouseDown = function(sender, args)
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
