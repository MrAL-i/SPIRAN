do
function run(msg, matches)
local reply_id = msg['id']
local text = 'info'
local text1 ="🔱group ID : "..msg.to.id.."\n🔱group name : "..msg.to.title.."\n🔱your name : "..(msg.from.first_name or '').."\n🔱first : "..(msg.from.first_name or '').."\n🔱last : "..(msg.from.last_name or '').."\n🔱user ID : "..msg.from.id.."\n🔱username : @"..(msg.from.username or '').."\n🔱phone number : +"..(msg.from.phone or '')
  reply_msg(reply_id, text1, ok_cb, false)
end
return {
  description = "", 
  usage = "",
  patterns = {
    "^[!/#]info$",
  },
  run = run
}
end
