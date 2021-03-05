local DARKRP_MONEY = Cosmo.ActionType.new("darkrp_money")

function DARKRP_MONEY:onBought(ply, data)
  if not data.amount then return end

  local amount = tonumber(data.amount)
  if not amount then return false end

  ply:addMoney(amount)
  return true
end