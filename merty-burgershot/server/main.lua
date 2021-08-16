ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)


RegisterServerEvent('ev-blackmarket:makeorder')
AddEventHandler('ev-blackmarket:makeorder', function(data)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local bankamount = xPlayer.getAccount('bank').money
    local price = tonumber(data.price)
    if bankamount >= price and price > 0 then
      xPlayer.removeAccountMoney('bank', price)
      TriggerClientEvent('notification', src, "You paid $"  ..price..  "for your order", 1)
    end
end)

RegisterServerEvent('merty:esyaekle')
AddEventHandler('merty:esyaekle', function(item, count)
  local player = ESX.GetPlayerFromId(source)
  player.addInventoryItem(item, count)
end)
