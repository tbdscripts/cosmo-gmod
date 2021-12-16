-- LEAVE THIS LINE
Cosmo.Config = Cosmo.Config or {}
-- LEAVE LINE ABOVE


--[[
    Instance Url
        - This is your site url, so for example our demo is "https://demo.tbdscripts.com"
        - Notice that there is NO trailing paths like /store or /forums
]]
Cosmo.Config.InstanceUrl = "https://your.domain"

--[[
    Donate Command
        - The command which opens your store
]]
Cosmo.Config.DonateCommand = "!donate"

--[[
    Notification Time
        - The time for which one notification stays visible
]]
Cosmo.Config.NotificationTime = 3

--[[
    Notification Theme
        - The colors and rounding options for the notifications
]]
Cosmo.Config.NotificationTheme = {
    Background = Color(30, 30, 30),
    Header = Color(40, 40, 40),

    Roundness = 6,
}

--[[
    Language
        - Translation strings, mainly for the notification
]]
Cosmo.Config.Language = {
    NotificationTitle = "Store Purchase",
    NotificationContent = ":player has purchased :package!"
}

--[[
    Log Level
        - You can probably just leave this to the default
]]
Cosmo.Config.LogLevel = Cosmo.Log.LEVEL_INFO