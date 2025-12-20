--=================================================================================================
--= Functions     
--= ===============================================================================================
--= utility functions
--=================================================================================================


function PrintAlert(text)
    
    if _G.Settings.printAlerts == false then
        return
    end

    Turbine.Shell.WriteLine(text)

end

function _G.TableContains(t, value)
    for i = 1, #t do
        if t[i] == value then
            return true
        end
    end
    return false
end