os.loadAPI("/serverutils.lua")
function randomId()

    return math.floor(math.random()*1000)
end
function checkBalances()
    local users = serverutils.readJsonFile("users.json")
    for i = 1,#users do
        if(users[i].balance == nil) then
            users[i].balance = 0
        end
    end
    serverutils.writeJsonFile("users.json",users)
    print("Checking user balances")
end



rednet.open("top")
rednet.host("transaction","transaction_server")


checkBalances()

while true do
    event,id,message,distance = os.pullEvent("rednet_message")
    if(message["message"] == "SELLITEMS") then
        local parameters = message.parameters
        local account_id = parameters[1]
        local items_sum = parameters[2]
        local users = serverutils.getUsers()
        local balance = serverutils.getBalance(users[account_id].username)
        serverutils.setBalance(users[account_id].username,balance + items_sum)
        rednet.send(id,"we have now transfered $"..tostring(items_sum).." to your account")


    end
    if(message["message"] == "GETLEDGER") then
        --print(.readJsonFile("ledger.json"))
        rednet.send(id,serverutils.readJsonFile("ledger.json"))
        print("request for ledger")
    end
    if(message["message"] == "GETUSERS") then

        rednet.send(id,serverutils.readJsonFile("./users.json"))
        print("request for users")
    end
    if(message.message == "GETUSERBALANCE") then
        local users = serverutils.getUsers()
        local balance = 0
        balance = users[message.parameters].balance
        rednet.send(id,balance)
    end
    if(message.message == "TRANSFERFUNDS") then
        local parameters = message.parameters
        account_id = parameters[1]
        username = parameters[2]
        amount = parameters[3]

        local users = serverutils.getUsers()
        if(tonumber(amount) < 0) then
            rednet.send(id,"Can't send negative dollars")

        else
            if(serverutils.userHasFunds(users[account_id].id,amount)) then
                s = serverutils.getBalance(account_id)
                serverutils.setBalance(account_id,s-amount)
                r = serverutils.getBalance(username)
                serverutils.setBalance(username,r+amount)
                rednet.send(id,"Successfully Transfered")
            else
               rednet.send(id,"Insufficient Funds")
            end
        end
    end
    if(message.message == "ADDPRICE") then
        local parameters = message.parameters
        --print(textutils.serialise(parameters))
        local item_name =  parameters[1]
        local item_price = parameters[2]
        if(serverutils.itemExist(item_name)) then
            rednet.send(id,"Item Already Exist")
        else
            serverutils.addPrice(item_name,item_price)
            rednet.send(id,"Successfully Added Price")
        end
    end
    if(message.message == "GETVALUE") then
        local prices = serverutils.getPrices()
        local parameters = message.parameters
        local item_name = parameters[1]
        if(serverutils.itemExist(item_name)) then
            rednet.send(id,prices[item_name].price)
        else
            rednet.send(id,0)
        end

    end
    if(message.message == "CHANGEPRICE") then
        local items = serverutils.getPrices()

        local parameters = message.parameters

        local item_name = parameters[1]
        local item_price = parameters[2]

        if(serverutils.itemExist(item_name)) then
            items[item_name].price = item_price
            items[items[item_name].index].price = item_price
            serverutils.setPrices(items)
            rednet.send(id,"Price was successfully changed")
        else
            rednet.send(id,"Item does not exist")
        end



    end
end


