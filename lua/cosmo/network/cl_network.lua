local trimRight = string.TrimRight

net.Receive("Cosmo.DonateCommand", function()
    local instUrl = trimRight(Cosmo.Config.InstanceUrl, "/")

    gui.OpenURL(instUrl .. "/store")
end)