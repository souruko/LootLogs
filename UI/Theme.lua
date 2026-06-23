--=================================================================================================
--= Theme
--= ===============================================================================================
--= Color theme definitions. _G.Theme is populated from the active theme on plugin load.
--=================================================================================================


_G.Themes = {

    -- Moria: dark cave gold (default — the original palette)
    moria = {
        BG      = {0.05, 0.04, 0.03},
        PANEL   = {0.07, 0.06, 0.04},
        SECTION = {0.10, 0.08, 0.04},
        HEADER  = {0.12, 0.10, 0.06},
        PRESS   = {0.18, 0.15, 0.08},
        SEL_BG  = {0.22, 0.18, 0.08},
        OUTER   = {0.22, 0.18, 0.12},
        FRAME   = {0.40, 0.33, 0.20},
        HOVER   = {0.65, 0.54, 0.28},
        DIM     = {0.45, 0.38, 0.26},
        DIM2    = {0.52, 0.45, 0.32},
        TEXT    = {0.73, 0.65, 0.50},
        ACCENT  = {1.00, 0.88, 0.55},
        STRIP   = {0.55, 0.45, 0.22},
    },

    -- Lorien: elven silver-green
    lorien = {
        BG      = {0.02, 0.04, 0.03},
        PANEL   = {0.04, 0.07, 0.05},
        SECTION = {0.04, 0.08, 0.05},
        HEADER  = {0.06, 0.10, 0.07},
        PRESS   = {0.10, 0.18, 0.12},
        SEL_BG  = {0.12, 0.22, 0.14},
        OUTER   = {0.12, 0.20, 0.14},
        FRAME   = {0.25, 0.40, 0.28},
        HOVER   = {0.40, 0.65, 0.45},
        DIM     = {0.38, 0.52, 0.40},
        DIM2    = {0.50, 0.65, 0.52},
        TEXT    = {0.70, 0.82, 0.72},
        ACCENT  = {0.88, 1.00, 0.90},
        STRIP   = {0.30, 0.52, 0.35},
    },

    -- Mordor: volcanic ash and ember
    mordor = {
        BG      = {0.04, 0.02, 0.02},
        PANEL   = {0.07, 0.04, 0.03},
        SECTION = {0.08, 0.04, 0.03},
        HEADER  = {0.10, 0.05, 0.04},
        PRESS   = {0.16, 0.08, 0.05},
        SEL_BG  = {0.20, 0.10, 0.06},
        OUTER   = {0.20, 0.10, 0.07},
        FRAME   = {0.38, 0.18, 0.10},
        HOVER   = {0.65, 0.28, 0.12},
        DIM     = {0.42, 0.25, 0.18},
        DIM2    = {0.52, 0.30, 0.22},
        TEXT    = {0.72, 0.60, 0.52},
        ACCENT  = {1.00, 0.60, 0.30},
        STRIP   = {0.50, 0.22, 0.08},
    },

    -- Rivendell: cool silver and starlight blue
    rivendell = {
        BG      = {0.02, 0.03, 0.05},
        PANEL   = {0.04, 0.05, 0.08},
        SECTION = {0.04, 0.06, 0.09},
        HEADER  = {0.06, 0.08, 0.12},
        PRESS   = {0.10, 0.14, 0.22},
        SEL_BG  = {0.14, 0.18, 0.28},
        OUTER   = {0.12, 0.16, 0.24},
        FRAME   = {0.28, 0.35, 0.50},
        HOVER   = {0.45, 0.58, 0.80},
        DIM     = {0.35, 0.42, 0.58},
        DIM2    = {0.45, 0.52, 0.66},
        TEXT    = {0.70, 0.75, 0.85},
        ACCENT  = {0.88, 0.94, 1.00},
        STRIP   = {0.35, 0.45, 0.65},
    },

    -- Rohan: amber and sun-baked earth
    rohan = {
        BG      = {0.04, 0.03, 0.01},
        PANEL   = {0.07, 0.05, 0.02},
        SECTION = {0.08, 0.06, 0.02},
        HEADER  = {0.11, 0.08, 0.03},
        PRESS   = {0.20, 0.15, 0.05},
        SEL_BG  = {0.24, 0.18, 0.06},
        OUTER   = {0.25, 0.18, 0.06},
        FRAME   = {0.48, 0.34, 0.10},
        HOVER   = {0.75, 0.54, 0.18},
        DIM     = {0.50, 0.40, 0.22},
        DIM2    = {0.58, 0.50, 0.30},
        TEXT    = {0.80, 0.70, 0.52},
        ACCENT  = {1.00, 0.82, 0.38},
        STRIP   = {0.60, 0.42, 0.12},
    },

    -- Wulf: deep violet and shadow-purple
    wulf = {
        BG      = {0.04, 0.02, 0.06},
        PANEL   = {0.07, 0.04, 0.10},
        SECTION = {0.10, 0.05, 0.14},
        HEADER  = {0.13, 0.07, 0.18},
        PRESS   = {0.20, 0.10, 0.28},
        SEL_BG  = {0.24, 0.12, 0.32},
        OUTER   = {0.28, 0.15, 0.38},
        FRAME   = {0.45, 0.25, 0.58},
        HOVER   = {0.65, 0.35, 0.80},
        DIM     = {0.52, 0.38, 0.62},
        DIM2    = {0.60, 0.48, 0.70},
        TEXT    = {0.82, 0.72, 0.90},
        ACCENT  = {0.92, 0.80, 1.00},
        STRIP   = {0.55, 0.30, 0.68},
    },

    -- Misty Mountain: light mode — snow, ice, pale sky
    misty = {
        BG      = {0.92, 0.93, 0.95},
        PANEL   = {0.86, 0.87, 0.90},
        SECTION = {0.78, 0.80, 0.84},
        HEADER  = {0.70, 0.72, 0.78},
        PRESS   = {0.60, 0.63, 0.70},
        SEL_BG  = {0.74, 0.80, 0.92},
        OUTER   = {0.45, 0.48, 0.55},
        FRAME   = {0.35, 0.38, 0.46},
        HOVER   = {0.28, 0.42, 0.70},
        DIM     = {0.30, 0.34, 0.42},
        DIM2    = {0.42, 0.46, 0.54},
        TEXT    = {0.15, 0.18, 0.25},
        ACCENT  = {0.10, 0.24, 0.58},
        STRIP   = {0.32, 0.44, 0.68},
    },

}

function _G.ApplyTheme(name)
    local t = _G.Themes[name] or _G.Themes.moria
    _G.Theme = {}
    for k, rgb in pairs(t) do
        _G.Theme[k] = Turbine.UI.Color(rgb[1], rgb[2], rgb[3])
    end
    _G.Theme.FONT_STYLE = (name == "misty")
        and Turbine.UI.FontStyle.None
        or  Turbine.UI.FontStyle.Outline
end

