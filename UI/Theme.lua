--=================================================================================================
--= Theme
--= ===============================================================================================
--= Color theme definitions. _G.Theme is populated from the active theme on plugin load.
--=
--= Roles used by the redesigned window (docs/design/window-redesign):
--=   ROW_ALT         background of every second data row
--=   CHIP_USED_*     "N common" chip  — completions consumed
--=   CHIP_FAV_*      "N favour" chip  — favoured completions consumed
--=   CHIP_DONE_*     "done" chip      — completed or locked until reset
--=   DASH            the dash shown where nothing is recorded
--=   SQUARE_EMPTY    border of an empty per-tier square in the sidebar
--=
--= The two used/favoured chips must never share a hue. Where the theme accent is already
--= warm (moria, mordor, rohan) the favoured chip takes a cool counterpoint instead of the
--= accent, so the pair stays one warm / one cool in every theme.
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

        ROW_ALT        = {0.09, 0.07, 0.05},
        CHIP_USED_BG   = {0.18, 0.14, 0.06},
        CHIP_USED_FRAME= {0.42, 0.33, 0.14},
        CHIP_USED_TEXT = {0.95, 0.78, 0.40},
        CHIP_FAV_BG    = {0.10, 0.11, 0.20},
        CHIP_FAV_FRAME = {0.28, 0.30, 0.52},
        CHIP_FAV_TEXT  = {0.74, 0.80, 1.00},
        CHIP_DONE_BG   = {0.10, 0.09, 0.07},
        CHIP_DONE_FRAME= {0.30, 0.26, 0.18},
        CHIP_DONE_TEXT = {0.48, 0.42, 0.32},
        DASH           = {0.34, 0.29, 0.22},
        SQUARE_EMPTY   = {0.28, 0.23, 0.15},
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

        ROW_ALT        = {0.05, 0.09, 0.06},
        CHIP_USED_BG   = {0.14, 0.12, 0.05},
        CHIP_USED_FRAME= {0.38, 0.32, 0.14},
        CHIP_USED_TEXT = {0.90, 0.78, 0.45},
        CHIP_FAV_BG    = {0.06, 0.13, 0.09},
        CHIP_FAV_FRAME = {0.24, 0.46, 0.32},
        CHIP_FAV_TEXT  = {0.80, 1.00, 0.86},
        CHIP_DONE_BG   = {0.05, 0.08, 0.06},
        CHIP_DONE_FRAME= {0.20, 0.30, 0.22},
        CHIP_DONE_TEXT = {0.40, 0.52, 0.42},
        DASH           = {0.30, 0.40, 0.32},
        SQUARE_EMPTY   = {0.18, 0.28, 0.20},
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

        ROW_ALT        = {0.09, 0.05, 0.04},
        CHIP_USED_BG   = {0.18, 0.10, 0.04},
        CHIP_USED_FRAME= {0.44, 0.24, 0.10},
        CHIP_USED_TEXT = {1.00, 0.66, 0.36},
        CHIP_FAV_BG    = {0.09, 0.10, 0.16},
        CHIP_FAV_FRAME = {0.26, 0.28, 0.44},
        CHIP_FAV_TEXT  = {0.74, 0.78, 0.96},
        CHIP_DONE_BG   = {0.09, 0.06, 0.05},
        CHIP_DONE_FRAME= {0.28, 0.16, 0.12},
        CHIP_DONE_TEXT = {0.46, 0.30, 0.24},
        DASH           = {0.34, 0.22, 0.18},
        SQUARE_EMPTY   = {0.26, 0.14, 0.10},
    },

    -- Rivendell: the palette Gibberish3's options panel uses, so both plugins look the
    -- same on screen. Every value below is a literal Options.Defaults.window.* token
    -- from Gibberish3/Defaults.lua — the token name is in the comment. Do not drift.
    rivendell = {
        BG      = {0.086, 0.094, 0.149},  -- bg          (PanelWindow root + client)
        PANEL   = {0.071, 0.078, 0.122},  -- bg_sunken   (columns, fields)
        SECTION = {0.114, 0.125, 0.196},  -- row_odd     (raised rows, headers)
        HEADER  = {0.114, 0.125, 0.196},  -- row_odd     (title bar)
        PRESS   = {0.071, 0.078, 0.122},  -- bg_sunken   (pressed sinks)
        SEL_BG  = {0.137, 0.153, 0.255},  -- select
        OUTER   = {0.180, 0.196, 0.314},  -- line
        FRAME   = {0.180, 0.196, 0.314},  -- line        (every border)
        HOVER   = {0.569, 0.518, 0.851},  -- accent      (interactive highlight)
        DIM     = {0.361, 0.376, 0.463},  -- text_faint
        DIM2    = {0.545, 0.561, 0.659},  -- text_muted
        TEXT    = {0.914, 0.914, 0.929},  -- text
        ACCENT  = {0.569, 0.518, 0.851},  -- accent
        STRIP   = {0.569, 0.518, 0.851},  -- accent

        ROW_ALT        = {0.102, 0.114, 0.173},  -- row_even
        CHIP_DONE_BG   = {0.086, 0.094, 0.149},  -- bg
        CHIP_DONE_FRAME= {0.180, 0.196, 0.314},  -- line
        CHIP_DONE_TEXT = {0.361, 0.376, 0.463},  -- text_faint
        DASH           = {0.290, 0.306, 0.400},  -- off_border
        SQUARE_EMPTY   = {0.145, 0.157, 0.243},  -- line, muted (no G3 token)
        -- the chips have no counterpart in Gibberish3, so these stay on the design
        -- system's own values, which are drawn for exactly this palette
        CHIP_USED_BG   = {0.180, 0.165, 0.110},  -- #2e2a1c
        CHIP_USED_FRAME= {0.290, 0.263, 0.188},  -- #4a4330
        CHIP_USED_TEXT = {0.878, 0.741, 0.478},  -- #e0bd7a
        CHIP_FAV_BG    = {0.169, 0.153, 0.255},  -- #2b2741
        CHIP_FAV_FRAME = {0.259, 0.227, 0.416},  -- #423a6a
        CHIP_FAV_TEXT  = {0.824, 0.808, 0.992},  -- #d2cefd
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

        ROW_ALT        = {0.09, 0.07, 0.03},
        CHIP_USED_BG   = {0.19, 0.14, 0.04},
        CHIP_USED_FRAME= {0.50, 0.36, 0.12},
        CHIP_USED_TEXT = {1.00, 0.80, 0.40},
        CHIP_FAV_BG    = {0.08, 0.10, 0.18},
        CHIP_FAV_FRAME = {0.26, 0.32, 0.52},
        CHIP_FAV_TEXT  = {0.76, 0.84, 1.00},
        CHIP_DONE_BG   = {0.10, 0.08, 0.04},
        CHIP_DONE_FRAME= {0.34, 0.26, 0.12},
        CHIP_DONE_TEXT = {0.50, 0.42, 0.26},
        DASH           = {0.38, 0.32, 0.20},
        SQUARE_EMPTY   = {0.32, 0.24, 0.10},
    },

    -- Wulf: hot pink and neon pink
wulf = {
    BG      = {0.03, 0.00, 0.02},
    PANEL   = {0.07, 0.01, 0.04},
    SECTION = {0.11, 0.02, 0.06},
    HEADER  = {0.16, 0.03, 0.09},
    PRESS   = {0.28, 0.04, 0.15},
    SEL_BG  = {0.38, 0.05, 0.20},
    OUTER   = {0.50, 0.08, 0.28},
    FRAME   = {0.72, 0.12, 0.42},
    HOVER   = {1.00, 0.00, 0.55},
    DIM     = {0.75, 0.35, 0.55},
    DIM2    = {0.88, 0.45, 0.65},
    TEXT    = {1.00, 0.88, 0.96},
    ACCENT  = {1.00, 0.15, 0.65},
    STRIP   = {1.00, 0.00, 0.45},

    ROW_ALT        = {0.09, 0.02, 0.05},
    CHIP_USED_BG   = {0.20, 0.12, 0.02},
    CHIP_USED_FRAME= {0.55, 0.34, 0.08},
    CHIP_USED_TEXT = {1.00, 0.76, 0.30},
    CHIP_FAV_BG    = {0.20, 0.02, 0.10},
    CHIP_FAV_FRAME = {0.72, 0.12, 0.42},
    CHIP_FAV_TEXT  = {1.00, 0.55, 0.80},
    CHIP_DONE_BG   = {0.10, 0.03, 0.06},
    CHIP_DONE_FRAME= {0.40, 0.14, 0.26},
    CHIP_DONE_TEXT = {0.62, 0.34, 0.48},
    DASH           = {0.55, 0.28, 0.42},
    SQUARE_EMPTY   = {0.45, 0.12, 0.28},
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

        -- light mode: chip fills sit above the panel, text below it
        ROW_ALT        = {0.82, 0.83, 0.87},
        CHIP_USED_BG   = {0.96, 0.90, 0.74},
        CHIP_USED_FRAME= {0.66, 0.52, 0.20},
        CHIP_USED_TEXT = {0.36, 0.26, 0.05},
        CHIP_FAV_BG    = {0.84, 0.88, 0.97},
        CHIP_FAV_FRAME = {0.34, 0.46, 0.72},
        CHIP_FAV_TEXT  = {0.08, 0.20, 0.50},
        CHIP_DONE_BG   = {0.84, 0.85, 0.88},
        CHIP_DONE_FRAME= {0.55, 0.58, 0.64},
        CHIP_DONE_TEXT = {0.42, 0.45, 0.52},
        DASH           = {0.52, 0.55, 0.62},
        SQUARE_EMPTY   = {0.58, 0.61, 0.68},
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

