
_G.Locale = {

    en = {
        -- sidebar
        customListBtn     = "Custom List",
        contentBtn        = "Content",
        charactersBtn     = "Characters",
        searchPlaceholder = "search ...",
        -- content view header types
        headerInstance    = "Instance  ",
        headerContent     = "Content  ",
        headerCharacter   = "Character  ",
        headerServer      = "Server  ",
        headerCustomList  = "List  ",
        -- content view header name (custom list)
        customListName    = "Custom List",
        -- content view empty messages
        emptyInstance     = "No events defined for this instance.",
        emptyContent      = "No instances defined for this content.",
        emptyCharacter    = "No logs recorded for this character.",
        emptyServer       = "No logs recorded for this server.",
        emptyCustomList   = "No Custom List items selected.",
        -- tier toggle hover
        customListHover   = "Add to / remove from Custom List",
        -- content row
        levelPrefix       = "Lv ",
        -- settings
        settingsTitle     = "Settings",
        toggleOn          = "ON",
        toggleOff         = "OFF",
        sectionChat       = "Chat",
        printAlerts       = "Print Alerts",
        printWelcome      = "Print Welcome",
        sectionDisplay    = "Display",
        showCustomList    = "Show Custom List",
        showServers       = "Show Servers",
        timezone          = "Timezone (UTC offset)",
        sectionLanguage   = "Display Language",
        sectionServer     = "Server",
    },

    de = {
        customListBtn     = "Eigene Liste",
        contentBtn        = "Inhalt",
        charactersBtn     = "Charaktere",
        searchPlaceholder = "suchen ...",
        headerInstance    = "Instanz  ",
        headerContent     = "Inhalt  ",
        headerCharacter   = "Charakter  ",
        headerServer      = "Server  ",
        headerCustomList  = "Liste  ",
        customListName    = "Eigene Liste",
        emptyInstance     = "Keine Events fuer diese Instanz definiert.",
        emptyContent      = "Keine Instanzen fuer diesen Inhalt definiert.",
        emptyCharacter    = "Keine Logs fuer diesen Charakter aufgezeichnet.",
        emptyServer       = "Keine Logs fuer diesen Server aufgezeichnet.",
        emptyCustomList   = "Keine Eintraege in der eigenen Liste.",
        customListHover   = "Zur eigenen Liste hinzufuegen / entfernen",
        levelPrefix       = "Lv ",
        settingsTitle     = "Einstellungen",
        toggleOn          = "AN",
        toggleOff         = "AUS",
        sectionChat       = "Chat",
        printAlerts       = "Benachrichtigungen",
        printWelcome      = "Begruessung",
        sectionDisplay    = "Anzeige",
        showCustomList    = "Eigene Liste anzeigen",
        showServers       = "Server anzeigen",
        timezone          = "Zeitzone (UTC Versatz)",
        sectionLanguage   = "Anzeigesprache",
        sectionServer     = "Server",
    },

    fr = {
        customListBtn     = "Liste perso",
        contentBtn        = "Contenu",
        charactersBtn     = "Personnages",
        searchPlaceholder = "rechercher ...",
        headerInstance    = "Instance  ",
        headerContent     = "Contenu  ",
        headerCharacter   = "Personnage  ",
        headerServer      = "Serveur  ",
        headerCustomList  = "Liste  ",
        customListName    = "Liste perso",
        emptyInstance     = "Aucun evenement defini pour cette instance.",
        emptyContent      = "Aucune instance definie pour ce contenu.",
        emptyCharacter    = "Aucun journal pour ce personnage.",
        emptyServer       = "Aucun journal pour ce serveur.",
        emptyCustomList   = "Aucun element dans la liste perso.",
        customListHover   = "Ajouter / retirer de la liste perso",
        levelPrefix       = "Nv ",
        settingsTitle     = "Parametres",
        toggleOn          = "OUI",
        toggleOff         = "NON",
        sectionChat       = "Chat",
        printAlerts       = "Alertes chat",
        printWelcome      = "Message de bienvenue",
        sectionDisplay    = "Affichage",
        showCustomList    = "Afficher liste perso",
        showServers       = "Afficher serveurs",
        timezone          = "Fuseau horaire (UTC)",
        sectionLanguage   = "Langue d'affichage",
        sectionServer     = "Serveur",
    },

}

function _G.L(key)
    local lang = (_G.Settings and _G.Settings.language) or "en"
    local t = _G.Locale[lang]
    if t and t[key] ~= nil then return t[key] end
    return _G.Locale["en"][key] or key
end
