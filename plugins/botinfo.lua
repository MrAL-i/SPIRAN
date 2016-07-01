do
    function run(msg, matches)
        
  local text = [[
✅SPIRAN is The best bot✅

Sudo : @Mr_AL_i

Bot id : https://telegram.me/Spiran_TG

دریافت راهنما : /help , /superhelp

]]
    return text
  end
end 

return {
  description = "about for bot.  ", 
  usage = {
    "Show bot about.",
  },
  patterns = {
    "^[!/]([Aa]lomina)$",
  }, 
  run = run,
}
