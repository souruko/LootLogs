

Settings = class(Turbine.UI.Control)
-- window constructor --------------------------------------------------------------------------
function Settings:Constructor()
	Turbine.UI.Control.Constructor( self )

    self:SetVisible(false)
	self:SetBackColor(Turbine.UI.Color(0.2, 0.2, 0.2))

end