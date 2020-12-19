net.Receive("Cosmo.PurchaseNotification", function()
  local ply = net.ReadEntity()
  local packageName = net.ReadString()
  if not (IsValid(ply) and packageName) then return end

  Cosmo:pushNotification(ply, packageName)
end)