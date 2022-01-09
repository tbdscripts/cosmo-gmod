Cosmo.Network = Cosmo.Network or {}

util.AddNetworkString("Cosmo.DonateCommand")
util.AddNetworkString("Cosmo.PackagePurchase")

function Cosmo.Network.OpenDonateCommand(ply)
    net.Start("Cosmo.DonateCommand")
    net.Send(ply)
end

function Cosmo.Network.SendPackagePurchased(ply, packageName)
    net.Start("Cosmo.PackagePurchase")
        net.WriteEntity(ply)
        net.WriteString(packageName)
    net.Broadcast()
end