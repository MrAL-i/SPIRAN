 
 
do
local Arian = 190772401 --put your id here(BOT OWNER ID)
local Sosha = 112985792
--local Sosha2 = 164484149
 
local function setrank(msg, name, value,receiver) -- setrank function
  local hash = nil
 
    hash = 'rank:variables'
 
  if hash then
    redis:hset(hash, name, value)
        return send_msg(receiver, '„ﬁ«„ »—«Ì  ('..name..') »Â  : '..value..' €ÌÌ— Ì«› ', ok_cb,  true)
  end
end
 
 
local function res_user_callback(extra, success, result) -- /info <username> function
  if success == 1 then  
  if result.username then
   Username = '@'..result.username
   else
   Username = '----'
  end
    local text = '‰«„ ò«„· : '..(result.first_name or '')..' '..(result.last_name or '')..'n'
               ..'ÌÊ“— ‰Ì„: '..Username..'n'
               ..'«ÌœÌ : '..result.peer_id..'nn'
        local hash = 'rank:variables'
        local value = redis:hget(hash, result.peer_id)
    if not value then
         if result.peer_id == tonumber(Arian) then
           text = text..'„ﬁ«„ : «œ„Ì‰ ò· nn'
           elseif result.peer_id == tonumber(Sosha) then
           text = text..'Rank : „œÌ— «—‘œ —»«  (Full Access Admin) nn'
           --elseif result.peer_id == tonumber(Sosha2) then
           --text = text..'Rank : „œÌ— «—‘œ —»«  (Full Access Admin) nn'
          elseif is_admin2(result.peer_id) then
           text = text..'„ﬁ«„ : «œ„Ì‰ nn'
          elseif is_owner2(result.peer_id, extra.chat2) then
           text = text..'„ﬁ«„ : „œÌ— ê—ÊÂ nn'
          elseif is_momod2(result.peer_id, extra.chat2) then
            text = text..'„ﬁ«„ : „œÌ— nn'
      else
            text = text..'„ﬁ«„ : ò«—»— nn'
         end
   else
   text = text..'„ﬁ«„ : '..value..'nn'
  end
  local uhash = 'user:'..result.peer_id
  local user = redis:hgetall(uhash)
  local um_hash = 'msgs:'..result.peer_id..':'..extra.chat2
  user_info_msgs = tonumber(redis:get(um_hash) or 0)
  text = text..' ⁄œ«œ ÅÌ«„ Â«Ì ›—” «œÂ : : '..user_info_msgs..'nn'
  text = text
  send_msg(extra.receiver, text, ok_cb,  true)
  else
        send_msg(extra.receiver, ' Username not found.', ok_cb, false)
  end
end
 
local function action_by_id(extra, success, result)  -- /info <ID> function
 if success == 1 then
 if result.username then
   Username = '@'..result.username
   else
   Username = '----'
 end
   local text = '‰«„ ò«„· : '..(result.first_name or '')..' '..(result.last_name or '')..'n'
               ..'ÌÊ“—‰Ì„: '..Username..'n'
               ..'«ÌœÌ : '..result.peer_id..'nn'
  local hash = 'rank:variables'
  local value = redis:hget(hash, result.peer_id)
  if not value then
         if result.peer_id == tonumber(Arian) then
           text = text..'„ﬁ«„ : Executive Admin nn'
           elseif result.peer_id == tonumber(Sosha) then
           text = text..'„ﬁ«„ : „œÌ— «—‘œ —»«  (Full Access Admin) nn'
           elseif result.peer_id == tonumber(Sosha2) then
           text = text..'„ﬁ«„ : „œÌ— «—‘œ —»«  (Full Access Admin) nn'
          elseif is_admin2(result.peer_id) then
           text = text..'„ﬁ«„ : «œ„Ì‰ nn'
          elseif is_owner2(result.peer_id, extra.chat2) then
           text = text..'„ﬁ«„ : „œÌ— ê—ÊÂ nn'
          elseif is_momod2(result.peer_id, extra.chat2) then
           text = text..'„ﬁ«„ : „œÌ— nn'
          else
           text = text..'„ﬁ«„ : ò«—»— nn'
          end
   else
    text = text..'„ﬁ«„ : '..value..'nn'
  end
  local uhash = 'user:'..result.peer_id
  local user = redis:hgetall(uhash)
  local um_hash = 'msgs:'..result.peer_id..':'..extra.chat2
  user_info_msgs = tonumber(redis:get(um_hash) or 0)
  text = text..' ⁄œ« ÅÌ«„ Â«Ì ò«—»— : '..user_info_msgs..'nn'
  text = text
  send_msg(extra.receiver, text, ok_cb,  true)
  else
  send_msg(extra.receiver, 'id not found.nuse : /info @username', ok_cb, false)
  end
end
 
local function action_by_reply(extra, success, result)-- (reply) /info  function
                if result.from.username then
                   Username = '@'..result.from.username
                   else
                   Username = '----'
                 end
  local text = '‰«„ ò«„· : '..(result.from.first_name or '')..' '..(result.from.last_name or '')..'n'
               ..'ÌÊ“—‰Ì„ : '..Username..'n'
               ..'«ÌœÌ : '..result.from.peer_id..'nn'
        local hash = 'rank:variables'
                local value = redis:hget(hash, result.from.peer_id)
                 if not value then
                    if result.from.peer_id == tonumber(Arian) then
                       text = text..'„ﬁ«„ : Executive Admin nn'
                           elseif result.peer_id == tonumber(Sosha) then
                   text = text..'„ﬁ«„ : „œÌ— «—‘œ —»«  (Full Access Admin) nn'
                  --elseif result.peer_id == tonumber(Sosha2) then
                  --text = text..'Rank : „œÌ— «—‘œ —»«  (Full Access Admin) nn'
                     elseif is_admin2(result.from.peer_id) then
                       text = text..'„ﬁ«„ : «œ„Ì‰ nn'
                     elseif is_owner2(result.from.peer_id, result.to.id) then
                       text = text..'„ﬁ«„ : „œÌ— ê—ÊÂ nn'
                     elseif is_momod2(result.from.peer_id, result.to.id) then
                       text = text..'„ﬁ«„ : „œÌ— nn'
                 else
                       text = text..'„ﬁ«„ : ò«—»— nn'
                        end
                  else
                   text = text..'„ﬁ«„ : '..value..'nn'
                 end
         local user_info = {}
  local uhash = 'user:'..result.from.peer_id
  local user = redis:hgetall(uhash)
  local um_hash = 'msgs:'..result.from.peer_id..':'..result.to.peer_id
  user_info_msgs = tonumber(redis:get(um_hash) or 0)
  text = text..' ⁄œ« ÅÌ«„ Â«Ì ò«—»— : '..user_info_msgs..'nn'
  text = text
  send_msg(extra.receiver, text, ok_cb, true)
end
 
local function action_by_reply2(extra, success, result)
local value = extra.value
setrank(result, result.from.peer_id, value, extra.receiver)
end
 
local function run(msg, matches)
 if matches[1]:lower() == 'setrank' then
  local hash = 'usecommands:'..msg.from.id
  redis:incr(hash)
  if not is_sudo(msg) then
    return "«Ì‰ œ” Ê— ›ﬁÿ »—«Ì «œ„Ì‰ Â«Ì «’·Ì —»«  ›⁄«· „Ì »«‘œ"
  end
  local receiver = get_receiver(msg)
  local Reply = msg.reply_id
  if msg.reply_id then
  local value = string.sub(matches[2], 1, 1000)
    msgr = get_message(msg.reply_id, action_by_reply2, {receiver=receiver, Reply=Reply, value=value})
  else
  local name = string.sub(matches[2], 1, 50)
  local value = string.sub(matches[3], 1, 1000)
  local text = setrank(msg, name, value)
 
  return text
  end
  end
 if matches[1]:lower() == 'info' and not matches[2] then
  local receiver = get_receiver(msg)
  local Reply = msg.reply_id
  if msg.reply_id then
    msgr = get_message(msg.reply_id, action_by_reply, {receiver=receiver, Reply=Reply})
  else
  if msg.from.username then
   Username = '@'..msg.from.username
   else
   Username = '----'
   end
         local url , res = http.request('http://api.gpmod.ir/time/')
if res ~= 200 then return "No connection" end
local jdat = json:decode(url)
-----------
if msg.from.phone then
                                numberorg = string.sub(msg.from.phone, 3)
                                number = "****0"..string.sub(numberorg, 0,6)
                                if string.sub(msg.from.phone, 0,2) == '98' then
                                        number = number.."nò‘Ê—: Ã„ÂÊ—Ì «”·«„Ì «Ì—«‰"
                                        if string.sub(msg.from.phone, 0,4) == '9891' then
                                                number = number.."n‰Ê⁄ ”Ì„ò«— : Â„—«Â «Ê·"
                                        elseif string.sub(msg.from.phone, 0,5) == '98932' then
                                                number = number.."n‰Ê⁄ ”Ì„ò«— :  «·Ì«"
                                        elseif string.sub(msg.from.phone, 0,4) == '9893' then
                                                number = number.."n‰Ê⁄ ”Ì„ò«— : «Ì—«‰”·"
                                        elseif string.sub(msg.from.phone, 0,4) == '9890' then
                                                number = number.."n‰Ê⁄ ”Ì„ò«— : «Ì—«‰”·"
                                        elseif string.sub(msg.from.phone, 0,4) == '9892' then
                                                number = number.."n‰Ê⁄ ”Ì„ò«— : —«Ì ·"
                                        else
                                                number = number.."n‰Ê⁄ ”Ì„ò«— : ”«Ì—"
                                        end
                                else
                                        number = number.."nò‘Ê—: Œ«—Ãn‰Ê⁄ ”Ì„ò«— : „ ›—ﬁÂ"
                                end
                        else
                                number = "-----"
                        end
--------------------
   local text = '‰«„: '..(msg.from.first_name or '----')..'n'
   local text = text..'›«„Ì· : '..(msg.from.last_name or '----')..'n'     
   local text = text..'ÌÊ“—‰Ì„ : '..Username..'n'
   local text = text..'«ÌœÌ : '..msg.from.id..'nn'
          local text = text..'‘„«—Â  ·›‰ : '..number..'n'
        local text = text..'“„«‰ : '..jdat.FAtime..'n'
        local text = text..' «—ÌŒ  : '..jdat.FAdate..'nn'
   local hash = 'rank:variables'
        if hash then
          local value = redis:hget(hash, msg.from.id)
          if not value then
                if msg.from.id == tonumber(Arian) then
                 text = text..'„ﬁ«„ : Executive Admin nn'
                 elseif msg.from.id == tonumber(Sosha) then
                 text = text..'„ﬁ«„ : Full Access Admin nn'
                elseif is_admin1(msg) then
                 text = text..'„ﬁ«„ : «œ„Ì‰ nn'
                elseif is_owner(msg) then
                 text = text..'„ﬁ«„ : „œÌ— ê—ÊÂ nn'
                elseif is_momod(msg) then
                 text = text..'„ﬁ«„ : „œÌ— nn'
                else
                 text = text..'„ﬁ«„ : ò«—»— nn'
                end
          else
           text = text..'„ﬁ«„ : '..value..'n'
          end
        end
         local uhash = 'user:'..msg.from.id
         local user = redis:hgetall(uhash)
         local um_hash = 'msgs:'..msg.from.id..':'..msg.to.id
         user_info_msgs = tonumber(redis:get(um_hash) or 0)
         text = text..' ⁄œ«œ ÅÌ«„ Â«Ì ò«—»—: '..user_info_msgs..'nn'
    if msg.to.type == 'chat' or msg.to.type == 'channel' then
         text = text..'‰«„ ê—ÊÂ : '..msg.to.title..'n'
     text = text..'«ÌœÌ ê—ÊÂ : '..msg.to.id..''
    end
        text = text
    return send_msg(receiver, text, ok_cb, true)
    end
  end
  if matches[1]:lower() == 'info' and matches[2] then
   local user = matches[2]
   local chat2 = msg.to.id
   local receiver = get_receiver(msg)
   if string.match(user, '^%d+$') then
          user_info('user#id'..user, action_by_id, {receiver=receiver, user=user, text=text, chat2=chat2})
    elseif string.match(user, '^@.+$') then
      username = string.gsub(user, '@', '')
      msgr = res_user(username, res_user_callback, {receiver=receiver, user=user, text=text, chat2=chat2})
   end
  end
end
 
return {
  description = 'Know your information or the info of a chat members.',
  usage = {
    '!info: Return your info and the chat info if you are in one.',
    '(Reply)!info: Return info of replied user if used by reply.',
    '!info <id>: Return the info's of the <id>.',
   '!info @<user_name>: return the member @<user_name> information from the current chat.',
        '!setrank <userid> <rank>: change members rank.',
        '(Reply)!setrank <rank>: change members rank.',
 },
 patterns = {
   "^[/#!]([Ii][Nn][Ff][Oo])$",
   "^[/!#]([Ii][Nn][Ff][Oo]) (.*)$",
        "^[/!#]([Ss][Ee][Tt][Rr][Aa][Nn][Kk]) (%d+) (.*)$",
        "^[/!#]([Ss][Ee][Tt][Rr][Aa][Nn][Kk]) (.*)$",
 },
 run = run
}
 
end
 
 