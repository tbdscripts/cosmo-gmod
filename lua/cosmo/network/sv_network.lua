Cosmo.Network = Cosmo.Network or {}

util.AddNetworkString("Cosmo.PurchaseNotification")
util.AddNetworkString("Cosmo.DonateCommand")

function Cosmo.Network:sendPurchaseNotification(ply, packageName)
  net.Start("Cosmo.PurchaseNotification")
    net.WriteEntity(ply)
    net.WriteString(packageName)
  net.Broadcast()
end

function Cosmo.Network:openDonateCommand(ply)
  net.Start("Cosmo.DonateCommand")
  net.Send(ply)
end