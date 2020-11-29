local DARKRP_MONEY = Cosmo.ActionType.new("darkrp_money")

function DARKRP_MONEY:handle(ply, data)
  local amount = data.amount
  if not amount then return false end

  ply:addMoney(amount)
  return true
end