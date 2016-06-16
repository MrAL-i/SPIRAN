package.path = package.path .. ';.luarocks/share/lua/5.2/?.lua'
  ..';.luarocks/share/lua/5.2/?/init.lua'
package.cpath = package.cpath .. ';.luarocks/lib/lua/5.2/?.so'

require("./bot/utils")

local f = assert(io.popen('/usr/bin/git describe --tags', 'r'))
VERSION = assert(f:read('*a'))
f:close()

-- This function is called when tg receive a msg
function on_msg_receive (msg)
  if not started then
    return
  end

  msg = backward_msg_format(msg)

  local receiver = get_receiver(msg)
  print(receiver)
  --vardump(msg)
  msg = pre_process_service_msg(msg)
  if msg_valid(msg) then
    msg = pre_process_msg(msg)
    if msg then
      match_plugins(msg)
    --  mark_read(receiver, ok_cb, false)
    end
  end
end

function ok_cb(extra, success, result)

end

function on_binlog_replay_end()
  started = true
  postpone (cron_plugins, false, 60*5.0)
  -- See plugins/isup.lua as an example for cron

  _config = load_config()

  -- load plugins
  plugins = {}
  load_plugins()
end

function msg_valid(msg)
  -- Don't process outgoing messages
  if msg.out then
    print('\27[36mNot valid: msg from us\27[39m')
    return false
  end

  -- Before bot was started
  if msg.date < os.time() - 5 then
    print('\27[36mNot valid: old msg\27[39m')
    return false
  end

  if msg.unread == 0 then
    print('\27[36mNot valid: readed\27[39m')
    return false
  end

  if not msg.to.id then
    print('\27[36mNot valid: To id not provided\27[39m')
    return false
  end

  if not msg.from.id then
    print('\27[36mNot valid: From id not provided\27[39m')
    return false
  end

  if msg.from.id == our_id then
    print('\27[36mNot valid: Msg from our id\27[39m')
    return false
  end

  if msg.to.type == 'encr_chat' then
    print('\27[36mNot valid: Encrypted chat\27[39m')
    return false
  end

  if msg.from.id == 777000 then
    --send_large_msg(*group id*, msg.text) *login code will be sent to GroupID*
    return false
  end

  return true
end

--
function pre_process_service_msg(msg)
   if msg.service then
      local action = msg.action or {type=""}
      -- Double ! to discriminate of normal actions
      msg.text = "!!tgservice " .. action.type

      -- wipe the data to allow the bot to read service messages
      if msg.out then
         msg.out = false
      end
      if msg.from.id == our_id then
         msg.from.id = 0
      end
   end
   return msg
end

-- Apply plugin.pre_process function
function pre_process_msg(msg)
  for name,plugin in pairs(plugins) do
    if plugin.pre_process and msg then
      print('Preprocess', name)
      msg = plugin.pre_process(msg)
    end
  end
  return msg
end

-- Go over enabled plugins patterns.
function match_plugins(msg)
  for name, plugin in pairs(plugins) do
    match_plugin(plugin, name, msg)
  end
end

-- Check if plugin is on _config.disabled_plugin_on_chat table
local function is_plugin_disabled_on_chat(plugin_name, receiver)
  local disabled_chats = _config.disabled_plugin_on_chat
  -- Table exists and chat has disabled plugins
  if disabled_chats and disabled_chats[receiver] then
    -- Checks if plugin is disabled on this chat
    for disabled_plugin,disabled in pairs(disabled_chats[receiver]) do
      if disabled_plugin == plugin_name and disabled then
        local warning = 'Plugin '..disabled_plugin..' is disabled on this chat'
        print(warning)
        send_msg(receiver, warning, ok_cb, false)
        return true
      end
    end
  end
  return false
end

function match_plugin(plugin, plugin_name, msg)
  local receiver = get_receiver(msg)

  -- Go over patterns. If one matches it's enough.
  for k, pattern in pairs(plugin.patterns) do
    local matches = match_pattern(pattern, msg.text)
    if matches then
      print("msg matches: ", pattern)

      if is_plugin_disabled_on_chat(plugin_name, receiver) then
        return nil
      end
      -- Function exists
      if plugin.run then
        -- If plugin is for privileged users only
        if not warns_user_not_allowed(plugin, msg) then
          local result = plugin.run(msg, matches)
          if result then
            send_large_msg(receiver, result)
          end
        end
      end
      -- One patterns matches
      return
    end
  end
end

-- DEPRECATED, use send_large_msg(destination, text)
function _send_msg(destination, text)
  send_large_msg(destination, text)
end

-- Save the content of _config to config.lua
function save_config( )
  serialize_to_file(_config, './data/config.lua')
  print ('saved config into ./data/config.lua')
end

-- Returns the config from config.lua file.
-- If file doesn't exist, create it.
function load_config( )
  local f = io.open('./data/config.lua', "r")
  -- If config.lua doesn't exist
  if not f then
    print ("Created new config file: data/config.lua")
    create_config()
  else
    f:close()
  end
  local config = loadfile ("./data/config.lua")()
  for v,user in pairs(config.sudo_users) do
    print("Sudo user: " .. user)
  end
  return config
end

-- Create a basic config.json file and saves it.
function create_config( )
  -- A simple config with basic plugins and ourselves as privileged user
  config = {
    enabled_plugins = {
   "active_user",
   "addbot",
   "admin",
   "anti_fwd",
   "anti_spam",
   "anti_reply",
   "aparat",
   "auto_leave",
   "azan",
   "banhammer",
   "bot",
   "broadcast",
   "calc",
   "cpu",
   "dad",
   "echo+",
   "echo+1",
   "echo",
   "expire",
   "feedback",
   "filtering",
   "get",
   "gif",
   "github",
   "google",
   "gps",
   "joke",
   "inpm",
   "inrealm",
   "instagram",
   "invite",
   "join",
   "leave_ban",
   "linkpv",
   "linkshorter",
   "msg_checks",
   "nerkh",
   "nerkharz",
   "onservice",
   "owners",
   "plugins",
   "qr",
   "remmsg",
   "sendplug",
   "set",
   "setabout",
   "social",
   "spam",
   "supergroup",
   "support",
   "time",
   "translate",
   "voice",
   "vote",
   "weather",
   "wiki",
   "me",
   "info",
   "banner",
   "fire",
   "music",
   "clash",
   "req",
   "stats",
   "writer",
   "sms",
   "setwlc",
   "getwlc",
   "addplug",
   "pass",
   "bye",
   "toPhoto_By_Reply",
   "toPhoto_Txt_img",
   "toStciker_By_Reply",
   "toSticker(Text_to_stick)",
   "nano",
   "filemanager",
   "delplug",
   "ls",
   "dog",
   "setcmd",
   "ip",
   "stmaker",
   "gituser",
   "anti_tag",
   "lock_emoji",
   "badwd",
   "lock_audio",
   "lock_gif",
   "lock_join", 
   "lock_share",
   "lock_photo",
   "lock_video",
   "type"

    },
    sudo_users = {121952579},--Sudo users
    moderation = {data = 'data/moderation.json'},
    about_text = [[ ]],
    help_text_realm = [[ ]],
    help_text = [[ ]],
	help_text_super =[[
Alominabot SuperGroup Commands:

ðŸ”·!owner
Ø¯Ø±ÛŒØ§ÙØª Ø¢ÛŒØ¯ÛŒ Ù…Ø¯ÛŒØ± Ø§ØµÙ„ÛŒ Ú¯Ø±ÙˆÙ‡

ðŸ”·!modlist
Ø¯Ø±ÛŒØ§ÙØª Ù„ÛŒØ³Øª Ù…Ø¹Ø§ÙˆÙ†Ø§Ù† Ø³ÙˆÙ¾Ø±Ú¯Ø±ÙˆÙ‡

ðŸ”·!block (Ø¢ÛŒØ¯ÛŒ ÙØ±Ø¯)
Ø§Ø®Ø±Ø§Ø¬ Ùˆ Ø§Ø¶Ø§ÙÙ‡ Ú©Ø±Ø¯Ù† ÛŒÚ© ÙØ±Ø¯ Ø¨Ù‡ Ù„ÛŒØ³Øª Ø¨Ù„Ø§Ú©

ðŸ”·!kick (Ø¢ÛŒØ¯ÛŒ ÙØ±Ø¯)
Ø§Ø®Ø±Ø§Ø¬ Ú©Ø±Ø¯Ù† ÙØ±Ø¯ÛŒ ØªÙˆØ³Ø· Ø§ÛŒØ¯ÛŒ

ðŸ”·!muteuser
Ø¨ÛŒ ØµØ¯Ø§ Ú©Ø±Ø¯Ù† ÙØ±Ø¯ ØªÙˆØ³Ø· Ø±ÛŒÙ¾Ù„ÛŒ ÛŒØ§ ÛŒÙˆØ²Ø±Ù†ÛŒÙ…
Ø¨Ø±Ø§ÛŒ Ø®Ø§Ø±Ø¬ Ú©Ø±Ø¯Ù† Ø§Ø² Ø¨ÛŒ ØµØ¯Ø§ Ø¯ÙˆØ¨Ø§Ø±Ù‡ Ø¯Ø³ØªÙˆØ± Ø±Ø§ Ø§Ø±Ø³Ø§Ù„ Ù†Ù…Ø§ÛŒÛŒØ¯

ðŸ”·!info
Ø¯Ø±ÛŒØ§ÙØª Ø§Ø·Ù„Ø§Ø¹Ø§Øª Ø®ÙˆØ¯

ðŸ”·!save (Ù…ØªÙ†) (Ù…ÙˆØ¶ÙˆØ¹)
Ø°Ø®ÛŒØ±Ù‡ ÛŒÚ© Ù…ØªÙ†

ðŸ”·!get (Ù…ÙˆØ¶ÙˆØ¹)
Ø¯Ø±ÛŒØ§ÙØª Ù…ØªÙ† Ø°Ø®ÛŒØ±Ù‡ Ø´Ø¯Ù‡

ðŸ”·!id
Ø¯Ø±ÛŒØ§ÙØª Ø¢ÛŒØ¯ÛŒ Ø³ÙˆÙ¾Ø±Ú¯Ø±ÙˆÙ‡ ÛŒØ§ ÛŒÚ© ÙØ±Ø¯

ðŸ”·!setowner
ØªÙ†Ø¸ÛŒÙ… Ú©Ø±Ø¯Ù† Ù…Ø¯ÛŒØ± Ø§ØµÙ„ÛŒ Ø³ÙˆÙ¾Ø±Ú¯Ø±ÙˆÙ‡

ðŸ”·!promote [ÛŒÙˆØ²Ø±Ù†ÛŒÙ…|Ø¢ÛŒØ¯ÛŒ] 
Ø§Ø¶Ø§ÙÙ‡ Ú©Ø±Ø¯Ù† Ù…Ø¯ÛŒØ± Ø¨Ù‡ Ø³ÙˆÙ¾Ø±Ú¯Ø±ÙˆÙ‡

ðŸ”·!demote [ÛŒÙˆØ²Ø±Ù†ÛŒÙ…|Ø¢ÛŒØ¯ÛŒ]
Ø­Ø°Ù Ú©Ø±Ø¯Ù† Ù…Ø¯ÛŒØ± Ø§Ø² Ø³ÙˆÙ¾Ø±Ú¯Ø±ÙˆÙ‡

ðŸ”·!setname (Ù†Ø§Ù… Ø¬Ø¯ÛŒØ¯ Ú¯Ø±ÙˆÙ‡)
ØªÙ†Ø¸ÛŒÙ… Ù†Ø§Ù… Ú¯Ø±ÙˆÙ‡

ðŸ”·!setphoto
ØªÙ†Ø¸ÛŒÙ… Ø¹Ú©Ø³ Ú¯Ø±ÙˆÙ‡

ðŸ”·!setrules
ØªÙ†Ø¸ÛŒÙ… Ù‚ÙˆØ§Ù†ÛŒÙ† Ú¯Ø±ÙˆÙ‡

ðŸ”·!setabout
ØªÙ†Ø¸ÛŒÙ… Ø´Ø±Ø­ Ú¯Ø±ÙˆÙ‡

ðŸ”·!newlink
Ø§ÛŒØ¬Ø§Ø¯ Ù„ÛŒÙ†Ú© Ø¬Ø¯ÛŒØ¯

ðŸ”·!link
Ø¯Ø±ÛŒØ§ÙØª Ù„ÛŒÙ†Ú©

ðŸ”·!linkpv
Ø§Ø±Ø³Ø§Ù„ Ù„ÛŒÙ†Ú© Ú¯Ø±ÙˆÙ‡ Ø¨Ù‡ Ù¾ÛŒÙˆÛŒ

ðŸ”·!rules
Ø¯Ø±ÛŒØ§ÙØª Ù‚ÙˆØ§Ù†ÛŒÙ†

ðŸ”·!lock [links|spam|Arabic|member|rtl|sticker|contacts|strict|fwd|reply]
Ù‚ÙÙ„ Ú©Ø±Ø¯Ù† ØªÙ†Ø¸ÛŒÙ…Ø§Øª Ø³ÙˆÙ¾Ø±Ú¯Ø±ÙˆÙ‡

ðŸ”·!unlock [links|spam|Arabic|member|rtl|sticker|contacts|strict|fwd|reply]
Ø¨Ø§Ø²Ú©Ø±Ø¯Ù† ØªÙ†Ø¸ÛŒÙ…Ø§Øª Ø³ÙˆÙ¾Ø±Ú¯Ø±ÙˆÙ‡

ðŸ”·!mute [chat|audio|gifs|photo|video|service]
Ø¨ÛŒ ØµØ¯Ø§ Ú©Ø±Ø¯Ù† ÛŒÚ© ØªØ§ÛŒÙ¾ Ø¯Ø± Ø³ÙˆÙ¾Ø±Ú¯Ø±ÙˆÙ‡

ðŸ”·!unmute [chat|audio|gifs|photo|video|service]
Ø¨Ø§ ØµØ¯Ø§ Ú©Ø±Ø¯Ù† ÛŒÚ© ØªØ§ÛŒÙ¾ Ø¯Ø± Ø³ÙˆÙ¾Ø±Ú¯Ø±ÙˆÙ‡ 

ðŸ”·!setflood [Ø¹Ø¯Ø¯]
ØªÙ†Ø¸ÛŒÙ… Ú©Ø±Ø¯Ù† Ø­Ø³Ø§Ø³ÛŒØª Ø§Ø³Ù¾Ù…

ðŸ”·!settings
Ø¯Ø±ÛŒØ§ÙØª ØªÙ†Ø¸ÛŒÙ…Ø§Øª Ø³ÙˆÙ¾Ø±Ú¯Ø±ÙˆÙ‡

ðŸ”·!banlist
Ø¯Ø±ÛŒØ§ÙØª Ù„ÛŒØ³Øª Ø§Ø¹Ø¶Ø§ÛŒ Ø¨Ù† Ø´Ø¯Ù‡

ðŸ”·!clean [rules|about|modlist|mutelist]
Ù¾Ø§Ú© Ú©Ø±Ø¯Ù† Ù‚ÙˆØ§Ù†ÛŒÙ† ØŒ Ø¯Ø±Ø¨Ø§Ø±Ù‡ ØŒ Ø§Ø¹Ø¶Ø§ÛŒ Ø¨ÛŒ ØµØ¯Ø§ Ùˆ Ù„ÛŒØ³Øª Ù…Ø¯ÛŒØ±Ø§Ù†

ðŸ”·!del
Ø­Ø°Ù ÛŒÚ© Ù¾ÛŒØ§Ù… ØªÙˆØ³Ø· Ø±ÛŒÙ¾Ù„ÛŒ Ø¯Ø± Ø³ÙˆÙ¾Ø±Ú¯Ø±ÙˆÙ‡

ðŸ”·!support
Ø¯Ø¹ÙˆØª Ø³Ø§Ø²Ù†Ø¯Ù‡ Ø±Ø¨Ø§Øª Ø¯Ø± ØµÙˆØ±Øª ÙˆØ¬ÙˆØ¯ Ù…Ø´Ú©Ù„ 
ÙÙ‚Ø· Ø¯Ø± ØµÙˆØ±Øª ÙˆØ¬ÙˆØ¯ Ù…Ø´Ú©Ù„ Ø¯Ø± Ú¯Ø±ÙˆÙ‡ Ø³Ø§Ø²Ù†Ø¯Ù‡ Ø±Ø§ Ø¯Ø¹ÙˆØª Ú©Ù†ÛŒØ¯ Ø¯Ø± ØºÛŒØ± Ø§ÛŒÙ† ØµÙˆØ±Øª Ú¯Ø±ÙˆÙ‡ Ø´Ù…Ø§ Ø­Ø°Ù Ø®ÙˆØ§Ù‡Ø¯ Ø´Ø¯ 

ðŸ”·!feedback (Ù…ØªÙ†)
Ø§Ø±Ø³Ø§Ù„ Ù¾ÛŒØ§Ù… Ø¨Ù‡ Ø³Ø§Ø²Ù†Ø¯Ù‡

ðŸ”·!addword Ú©Ù„Ù…Ù‡
Ø§Ø¶Ø§ÙÙ‡ Ú©Ø±Ø¯Ù† ÛŒÚ© Ú©Ù„Ù…Ù‡ Ø¨Ù‡ Ù„ÛŒØ³Øª ÙÛŒÙ„ØªØ±

ðŸ”·!rw Ú©Ù„Ù…Ù‡
Ø­Ø°Ù ÛŒÚ© Ú©Ù„Ù…Ù‡ Ø§Ø² Ù„ÛŒØ³Øª ÙÛŒÙ„ØªØ±ÛŒÙ†Ú¯ 

ðŸ”·!badwords
Ø¯Ø±ÛŒØ§ÙØª Ù„ÛŒØ³Øª ÙÛŒÙ„ØªØ±ÛŒÙ†Ú¯ 

ðŸ”·!msgrem (Ø¹Ø¯Ø¯ÛŒ Ø²ÛŒØ± 100)
Ø­Ø°Ù Ù¾ÛŒØ§Ù… Ù‡Ø§ÛŒ Ø³ÙˆÙ¾Ø±Ú¯Ø±ÙˆÙ‡ Ø¨Ù‡ ØµÙˆØ±Øª Ø¹Ø¯Ø¯ÛŒ

ðŸ”·!msguser 
Ø¯Ø±ÛŒØ§ÙØª Ù„ÛŒØ³Øª Ù¾ÛŒØ§Ù… Ù‡Ø§ÛŒ Ø§ÙØ±Ø§Ø¯

ðŸ”·!bot off
Ø®Ø§Ù…ÙˆØ´ Ú©Ø±Ø¯Ù† Ø±Ø¨Ø§Øª Ø¯Ø± Ú¯Ø±ÙˆÙ‡

ðŸ”·!bot on
Ø±ÙˆØ´Ù† Ú©Ø±Ø¯Ù† Ø±Ø¨Ø§Øª Ø¯Ø± Ú¯Ø±ÙˆÙ‡

ðŸ”·!join support
Ø¹Ø¶Ùˆ Ø´Ø¯Ù† Ø¯Ø± Ú¯Ø±ÙˆÙ‡ Ù¾Ø´ØªÛŒØ¨Ø§Ù†ÛŒ Ø±Ø¨Ø§Øª

ðŸ”·!social
Ø¯Ø±ÛŒØ§ÙØª Ø±Ø§Ù‡Ù†Ù…Ø§ÛŒ ØªÙØ±ÛŒØ­ÛŒ
ðŸ”·!t2s (text) (color) (font)
Ø³Ø§Ø®Øª Ø§Ø³ØªÛŒÚ©Ø± Ø±Ù†Ú¯ÛŒ 

ðŸ”·!sticker
ØªØ¨Ø¯ÛŒÙ„ Ø¨Ù‡ Ø§Ø³ØªÛŒÚ©Ø± 

ðŸ”·!image
ØªØ¨Ø¯ÛŒÙ„ Ø¨Ù‡ Ø¹Ú©Ø³

ðŸ”·!file 
ØªØ¨Ø¯ÛŒÙ„ Ø¨Ù‡ ÙØ§ÛŒÙ„ 

ðŸ”·!banner
Ø³Ø§Ø®Øª Ø¨Ù†Ø±

@Alominateam
]],
  }
  serialize_to_file(config, './data/config.lua')
  print('saved config into ./data/config.lua')
end

function on_our_id (id)
  our_id = id
end

function on_user_update (user, what)
  --vardump (user)
end

function on_chat_update (chat, what)
  --vardump (chat)
end

function on_secret_chat_update (schat, what)
  --vardump (schat)
end

function on_get_difference_end ()
end

-- Enable plugins in config.json
function load_plugins()
  for k, v in pairs(_config.enabled_plugins) do
    print("Loading plugin", v)

    local ok, err =  pcall(function()
      local t = loadfile("plugins/"..v..'.lua')()
      plugins[v] = t
    end)

    if not ok then
      print('\27[31mError loading plugin '..v..'\27[39m')
	  print(tostring(io.popen("lua plugins/"..v..".lua"):read('*all')))
      print('\27[31m'..err..'\27[39m')
    end

  end
end

-- custom add
function load_data(filename)

	local f = io.open(filename)
	if not f then
		return {}
	end
	local s = f:read('*all')
	f:close()
	local data = JSON.decode(s)

	return data

end

function save_data(filename, data)

	local s = JSON.encode(data)
	local f = io.open(filename, 'w')
	f:write(s)
	f:close()

end


-- Call and postpone execution for cron plugins
function cron_plugins()

  for name, plugin in pairs(plugins) do
    -- Only plugins with cron function
    if plugin.cron ~= nil then
      plugin.cron()
    end
  end

  -- Called again in 2 mins
  postpone (cron_plugins, false, 120)
end

-- Start and load values
our_id = 0
now = os.time()
math.randomseed(now)
started = false
