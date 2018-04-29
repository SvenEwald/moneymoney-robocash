WebBanking {
  version = 0.1,
  url = "https://robo.cash/",
  services = { "RoboCash Account" }
}

local connection

function SupportsBank (protocol, bankCode)
  return protocol == ProtocolWebBanking and bankCode == "RoboCash Account"
end

function InitializeSession (protocol, bankCode, username, username2, password, username3)
  connection = Connection()
  local html = HTML(connection:get(url))
  local csrfToken = html:xpath("//*[@id='login_dialog']/input[@name='_token']"):val()
  print(csrfToken)
  content, charset, mimeType = connection:request("POST",
    "https://robo.cash/login",
    "email=" .. username .. "&password=" .. password .. "&_token=" .. csrfToken,
    "application/x-www-form-urlencoded; charset=UTF-8")

  if string.match(connection:getBaseURL(), 'login') then
    return LoginFailed
  end
end

function ListAccounts (knownAccounts)
  -- Return array of accounts.
  local account = {
    name = "Robocash Account",
    owner = "",
    accountNumber = "1",
    bankCode = "1",
    currency = "EUR",
    type = AccountTypeGiro
  }
  return {account}
end


function RefreshAccount (account, since)
  local s = {}
  content = HTML(connection:get("https://robo.cash/cabinet/summary"))
  local xxx = content:xpath("//value-with-roundings")
  local cash=xxx:get(1):attr("value")
  invested=xxx:get(2):attr("value")
  return {balance=tonumber(invested) ,transactions={}}
end


function EndSession ()
  connection:get("https://robo.cash/logout")
  return nil
end
