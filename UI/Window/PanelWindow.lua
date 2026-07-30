-- Frameless window chrome, shared by every LootLogs window.
--
-- Turbine.UI.Window draws nothing on its own, so this supplies the parts the
-- Lotro window used to give us for free: a 1px border, a 30px title bar that
-- drags the window, a close button and an optional resize gripper.
--
-- Subclasses put their content in self.client and implement OnLayout(w, h),
-- which is called with the client size whenever the window resizes.
-- self:TitleBarRight() is the x a subclass may place its own title-bar
-- buttons up to (it sits left of the close button).
--
-- This mirrors Gibberish3's OPTIONS2/ELEMENTS/PanelWindow.lua so both plugins
-- share one window language; only the colours are swapped for _G.Theme roles.

local BORDER, TITLE_H, PAD, GAP, BTN_SIZE, BTN_ICON, GRIP

-- recomputed when the Font Size setting changes
local function Metrics()
    BORDER           = 1
    TITLE_H          = _G.Scaled(30)
    PAD              = _G.Scaled(8)
    GAP              = _G.Scaled(8)
    BTN_SIZE         = 22
    BTN_ICON         = 16
    GRIP             = 14
end

_G.RegisterMetrics(Metrics)

_G.PanelWindow = class(Turbine.UI.Window)

function _G.PanelWindow:Constructor(config)
    Turbine.UI.Window.Constructor(self)

    config = config or {}
    self._resizable = (config.resizable == true)
    self._min_w     = config.min_width  or 200
    self._min_h     = config.min_height or 120
    self._dragging  = false
    self._sizing    = false

    -- the window's own fill is the 1px border; root covers everything inside it
    self:SetBackColor(_G.Theme.FRAME)

    self.root = Turbine.UI.Control()
    self.root:SetParent(self)
    self.root:SetPosition(BORDER, BORDER)
    self.root:SetBackColor(_G.Theme.BG)

    -- title bar (also the drag handle) --------------------------------------------------------
    self.titlebar = Turbine.UI.Control()
    self.titlebar:SetParent(self.root)
    self.titlebar:SetPosition(0, 0)
    self.titlebar:SetHeight(TITLE_H)
    self.titlebar:SetBackColor(_G.Theme.HEADER)
    self.titlebar:SetMouseVisible(true)

    self.titlebar.MouseDown = function(sender, args)
        if args.Button ~= Turbine.UI.MouseButton.Left then return end
        self:Activate()
        self._dragging = true
        self._drag_x   = args.X
        self._drag_y   = args.Y
    end

    self.titlebar.MouseMove = function(sender, args)
        if not self._dragging then return end
        local left, top = self:GetPosition()
        self:SetPosition(left + (args.X - self._drag_x), top + (args.Y - self._drag_y))
    end

    self.titlebar.MouseUp = function(sender, args)
        if not self._dragging then return end
        self._dragging = false
        if self.OnMoved ~= nil then self:OnMoved() end
    end

    self.title_label = Turbine.UI.Label()
    self.title_label:SetMultiline(false)
    self.title_label:SetParent(self.titlebar)
    self.title_label:SetPosition(PAD, 0)
    self.title_label:SetHeight(TITLE_H)
    self.title_label:SetFont(_G.Font(12))
    self.title_label:SetFontStyle(_G.Theme.FONT_STYLE)
    self.title_label:SetForeColor(_G.Theme.TEXT)
    self.title_label:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
    self.title_label:SetMarkupEnabled(true)
    self.title_label:SetMouseVisible(false)

    self.btn_close = Turbine.UI.Control()
    self.btn_close:SetParent(self.titlebar)
    self.btn_close:SetSize(BTN_SIZE, BTN_SIZE)
    self.btn_close:SetBackColor(_G.Theme.SEL_BG)
    self.btn_close:SetMouseVisible(true)

    local close_icon = Turbine.UI.Control()
    close_icon:SetParent(self.btn_close)
    close_icon:SetSize(BTN_ICON, BTN_ICON)
    close_icon:SetPosition(math.floor((BTN_SIZE - BTN_ICON) / 2),
                           math.floor((BTN_SIZE - BTN_ICON) / 2))
    close_icon:SetBlendMode(Turbine.UI.BlendMode.Overlay)
    close_icon:SetBackground("LootLogs/Ressources/cross.tga")
    close_icon:SetMouseVisible(false)

    self.btn_close.MouseEnter = function()
        self.btn_close:SetBackColor(_G.Theme.FRAME)
    end
    self.btn_close.MouseLeave = function()
        self.btn_close:SetBackColor(_G.Theme.SEL_BG)
    end
    self.btn_close.MouseClick = function() self:CloseWindow() end

    self.title_sep = Turbine.UI.Control()
    self.title_sep:SetParent(self.root)
    self.title_sep:SetHeight(BORDER)
    self.title_sep:SetBackColor(_G.Theme.FRAME)
    self.title_sep:SetMouseVisible(false)

    -- client area -----------------------------------------------------------------------------
    self.client = Turbine.UI.Control()
    self.client:SetParent(self.root)
    self.client:SetPosition(0, TITLE_H + BORDER)
    self.client:SetBackColor(_G.Theme.BG)

    -- content lives in the client, so GetParent() no longer reaches the window;
    -- this is how a child finds it (see Sidebar:Window(), Settings:Window())
    self.client.window = self

    -- resize gripper --------------------------------------------------------------------------
    if self._resizable then
        self.gripper = Turbine.UI.Control()
        self.gripper:SetParent(self.root)
        self.gripper:SetSize(GRIP, GRIP)
        self.gripper:SetBackColor(_G.Theme.FRAME)
        self.gripper:SetMouseVisible(true)

        self.gripper.MouseDown = function(sender, args)
            if args.Button ~= Turbine.UI.MouseButton.Left then return end
            self._sizing = true
            self._size_x = args.X
            self._size_y = args.Y
        end

        self.gripper.MouseMove = function(sender, args)
            if not self._sizing then return end
            local width, height = self:GetSize()
            self:SetSize(
                math.max(self._min_w, width  + (args.X - self._size_x)),
                math.max(self._min_h, height + (args.Y - self._size_y)))
        end

        self.gripper.MouseUp = function(sender, args)
            if not self._sizing then return end
            self._sizing = false
            if self.OnResized ~= nil then self:OnResized() end
        end

        self.gripper.MouseEnter = function()
            self.gripper:SetBackColor(_G.Theme.ACCENT)
        end
        self.gripper.MouseLeave = function()
            self.gripper:SetBackColor(_G.Theme.FRAME)
        end
    end

end

-- a flat title-bar button: no border, resting fill, hover fill, 16px white glyph
function _G.PanelWindow:MakeTitleButton(icon, onClick)

    local btn = Turbine.UI.Control()
    btn:SetParent(self.titlebar)
    btn:SetSize(BTN_SIZE, BTN_SIZE)
    btn:SetBackColor(_G.Theme.SEL_BG)
    btn:SetMouseVisible(true)

    local image = Turbine.UI.Control()
    image:SetParent(btn)
    image:SetSize(BTN_ICON, BTN_ICON)
    image:SetPosition(math.floor((BTN_SIZE - BTN_ICON) / 2),
                      math.floor((BTN_SIZE - BTN_ICON) / 2))
    image:SetBlendMode(Turbine.UI.BlendMode.Overlay)
    image:SetBackground(icon)
    image:SetMouseVisible(false)

    btn.MouseEnter = function() btn:SetBackColor(_G.Theme.FRAME) end
    btn.MouseLeave = function() btn:SetBackColor(_G.Theme.SEL_BG) end
    btn.MouseClick = onClick

    return btn

end

function _G.PanelWindow:SetTitleText(text)
    self.title_label:SetText(text)
end

-- x that a subclass's own title-bar buttons must stay left of
function _G.PanelWindow:TitleBarRight()
    return self._title_right or 0
end

-- default close: hide. Subclasses override to also persist their open flag.
function _G.PanelWindow:CloseWindow()
    self:SetVisible(false)
end

function _G.PanelWindow:SizeChanged()

    if self.root == nil then return end

    local width, height = self:GetSize()
    local rw = math.max(0, width  - 2 * BORDER)
    local rh = math.max(0, height - 2 * BORDER)

    self.root:SetSize(rw, rh)

    self.titlebar:SetWidth(rw)
    self.title_sep:SetPosition(0, TITLE_H)
    self.title_sep:SetWidth(rw)

    local close_left = rw - PAD - BTN_SIZE
    self.btn_close:SetPosition(close_left, math.floor((TITLE_H - BTN_SIZE) / 2))
    self._title_right = close_left - GAP

    local client_h = math.max(0, rh - TITLE_H - BORDER)
    self.client:SetSize(rw, client_h)

    if self.gripper ~= nil then
        self.gripper:SetPosition(rw - GRIP, rh - GRIP)
    end

    if self.OnLayout ~= nil then self:OnLayout(rw, client_h) end

end
