

ContentView = class(Turbine.UI.Control)
-- window constructor --------------------------------------------------------------------------
function ContentView:Constructor()
	Turbine.UI.Control.Constructor( self )

	self:SetBackColor(Turbine.UI.Color(0.2, 0.2, 0.2))

    self.background1 = Turbine.UI.Control()
    self.background1:SetParent(self)
    self.background1:SetBackColor(Turbine.UI.Color.Black)
    self.background1:SetPosition(5, 5)
 
    self.frame1 = Turbine.UI.Control()
    self.frame1:SetParent(self.background1)
    self.frame1:SetBackColor(Turbine.UI.Color(0.4, 0.4, 0.4))
    self.frame1:SetPosition(5, 5)

    self.background2 = Turbine.UI.Control()
    self.background2:SetParent(self.frame1)
    self.background2:SetBackColor(Turbine.UI.Color.Black)
    self.background2:SetPosition(1, 1)
    
end

function ContentView:SizeChanged()
    
    local width, height = self:GetSize()

    self.background1:SetSize(width - 10, height - 10)
    self.frame1:SetSize(width - 20, height - 20)
    self.background2:SetSize(width - 22, height - 22)

end