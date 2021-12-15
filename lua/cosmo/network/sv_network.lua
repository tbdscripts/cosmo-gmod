Cosmo.Network = Cosmo.Network or {}

util.AddNetworkString("Cosmo.DonateCommand")

function Cosmo.Network.OpenDonateCommand(ply)
    net.Start("Cosmo.DonateCommand")
    net.Send(ply)
end