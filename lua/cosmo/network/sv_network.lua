Cosmo.Network = Cosmo.Network or {}

util.AddNetworkString("Cosmo.PurchaseNotification")

function Cosmo.Network:sendPurchaseNotification(ply, packageName)
  net.Start("Cosmo.PurchaseNotification")
    net.WriteEntity(ply)
    net.WriteString(packageName)
  net.Broadcast()
end