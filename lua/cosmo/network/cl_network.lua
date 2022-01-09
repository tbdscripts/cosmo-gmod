local trimRight = string.TrimRight

net.Receive("Cosmo.DonateCommand", function()
    local instUrl = trimRight(Cosmo.Config.InstanceUrl, "/")

    gui.OpenURL(instUrl .. "/store")
end)

net.Receive("Cosmo.PackagePurchase", function()
    local ply = net.ReadEntity()
    local packageName = net.ReadString()

    if not (ply and packageName) then return end

    Cosmo.PushNotification(ply, packageName)
end)