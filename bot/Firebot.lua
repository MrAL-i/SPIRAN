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
   "type",
   "short",
   "ingroup",
   "Warn",
   "mean"

    },
    sudo_users = {95837751},--Sudo users
    moderation = {data = 'data/moderation.json'},
    about_text = [[ ]],
    help_text_realm = [[دستورات ریلیم(گروه) :
 
!creategroup [ نام ] 
ایجاد یک گروه 
 
!createrealm [ نام ] 
ایجاد یک قلمرو 
 
! setname [ نام ] 
تنظیم نام قلمرو 
 
!setabout [group|sgroup] [GroupID] [text] 
تنظیم یک گروه در مورد توضيحات
 
! setrules [ GroupID ] [ متن ] 
تنظیم قوانین یک گروه 
 
!lock [GroupID] [settings]
قفل کردن تنظيمات یک گروه است 
 
!unlock [GroupID] [settings]
بازكردن قفل تنظيمات یک گروه است

!settings [group|sgroup] [GroupID]
تنظيم كردن تنظيمات براي گروه

!wholist
دريافت ليست افراد در گروه يا ريلم 
 
!who
دريافت فايل از افراد در گروه يا ريلم

!type
دريافت نوع گروه
 
!kill chat [GroupID]
نابودي همه ي افراد و پاك كردن گروه

 
!kill realm [RealmID]
حذف و اخراج همه ي اعضاي ريلم و پاك كرن ريلم 
 
!addadmin [ id | نام کاربری ] 
ارتقای یک مدیر با id یا نام کاربری * توسط سودو يا ادمين(صاحب)
 
!removeadmin [ id | نام کاربری ] 
تنزل كردن يك مدير توسط id و نام كاربري * توسط سودو يا ادمين(صاحب)

!list groups
دريافت يك ليست از همه ي گروه ها
 
!list realms
 دريافت يك ليست از همه ي قلمرو ها

!support
ارتقاي يك كاربر به ساپورت

!-support
تنزل يك كاربر از ساپورت

!log
دريافت لوگ يا پرونده ي فعلي گروه يا ريلم 
 
!broadcast [text]
!broadcast Hello !
ارسال متن به همه گروه‌ها 
فقط sudo ها می‌توانند از این فرمان استفاده كنند. 

!bc [group_id] [text]
!bc 123456789 Hello !
اين دستور ارسال خواهد شد به [ايدي گروه مورد نظر]
 
 
* * شما می‌توانید از "#" , "!" , "/"  و یا " / " برای همه فرمان‌ها استفاده كنيد.
 
* فقط admins و sudo می‌توانند كه ربات هايي را در گروه ادد كنند.
 
* فقط admins و sudo می‌تواند از ممنوعیت ، unban ، newlink ، setphoto ، setname ، قفل كردن و بازكردن ، تنظيم قوانین و تنظيم توضيحات و درباره و تظيمات دستور ها استفاده كنند.
 
* فقط admins و sudo می‌توانند از  فرمان‌های setowner ، و اطلاعات يوزر موردنظر و دستورات خاص استفاده كنند.

🔰Spiran_TG🔰@SPIRAN_CHANNEL
FOLLOW US...
SPIRAN TEAM😘]],
    help_text = [[Commands list :
!kick [username|id]
You can also do it by reply
!ban [ username|id]
You can also do it by reply
!unban [id]
You can also do it by reply
!who
Members list
!modlist
Moderators list
!promote [username]
Promote someone
!demote [username]
Demote someone
!kickme
Will kick user
!about
Group description
!setphoto
Set and locks group photo
!setname [name]
Set group name
!rules
Group rules
!id
return group id or user id
!help
Returns help text
!lock [links|flood|spam|Arabic|member|rtl|sticker|contacts|strict]
Lock group settings
*rtl: Kick user if Right To Left Char. is in name*
!unlock [links|flood|spam|Arabic|member|rtl|sticker|contacts|strict]
Unlock group settings
*rtl: Kick user if Right To Left Char. is in name*
!mute [all|audio|gifs|photo|video]
mute group message types
*If "muted" message type: user is kicked if message type is posted 
!unmute [all|audio|gifs|photo|video]
Unmute group message types
*If "unmuted" message type: user is not kicked if message type is posted 
!set rules <text>
Set <text> as rules
!set about <text>
Set <text> as about
!settings
Returns group settings
!muteslist
Returns mutes for chat
!muteuser [username]
Mute a user in chat
*user is kicked if they talk
*only owners can mute | mods and owners can unmute
!mutelist
Returns list of muted users in chat
!newlink
create/revoke your group link
!link
returns group link
!owner
returns group owner id
!setowner [id]
Will set id as owner
!setflood [value]
Set [value] as flood sensitivity
!stats
Simple message statistics
!save [value] <text>
Save <text> as [value]
!get [value]
Returns text of [value]
!clean [modlist|rules|about]
Will clear [modlist|rules|about] and set it to nil
!res [username]
returns user id
"!res @username"
!log
Returns group logs
!banlist
will return group ban list
**You can use "#", "!", or "/" to begin all commands
*Only owner and mods can add bots in group
*Only moderators and owner can use kick,ban,unban,newlink,link,setphoto,setname,lock,unlock,set rules,set about and settings commands
*Only owner can use res,setowner,promote,demote and log commands
 ]],
	help_text_super =[[
Alominabot SuperGroup Commands:
🔷!owner
دریافت آیدی مدیر اصلی گروه
🔷!modlist
دریافت لیست معاونان سوپرگروه
🔷!block (آیدی فرد)
اخراج و اضافه کردن یک فرد به لیست بلاک
🔷!kick (آیدی فرد)
اخراج کردن فردی توسط ایدی
🔷!muteuser
بی صدا کردن فرد توسط ریپلی یا یوزرنیم
برای خارج کردن از بی صدا دوباره دستور را ارسال نمایید
🔷!info
دریافت اطلاعات خود
🔷!save (متن) (موضوع)
ذخیره یک متن
🔷!get (موضوع)
دریافت متن ذخیره شده
🔷!id
دریافت آیدی سوپرگروه یا یک فرد
🔷!setowner
تنظیم کردن مدیر اصلی سوپرگروه
🔷!promote [یوزرنیم|آیدی] 
اضافه کردن مدیر به سوپرگروه
🔷!demote [یوزرنیم|آیدی]
حذف کردن مدیر از سوپرگروه
🔷!setname (نام جدید گروه)
تنظیم نام گروه
🔷!setphoto
تنظیم عکس گروه
🔷!setrules
تنظیم قوانین گروه
🔷!setabout
تنظیم شرح گروه
🔷!newlink
ایجاد لینک جدید
🔷!link
دریافت لینک
🔷!linkpv
ارسال لینک گروه به پیوی
🔷!rules
دریافت قوانین
🔷!lock [links|spam|Arabic|member|rtl|sticker|contacts|strict|fwd|reply]
قفل کردن تنظیمات سوپرگروه
🔷!unlock [links|spam|Arabic|member|rtl|sticker|contacts|strict|fwd|reply]
بازکردن تنظیمات سوپرگروه
🔷!mute [chat|audio|gifs|photo|video|service]
بی صدا کردن یک تایپ در سوپرگروه
🔷!unmute [chat|audio|gifs|photo|video|service]
با صدا کردن یک تایپ در سوپرگروه 
🔷!setflood [عدد]
تنظیم کردن حساسیت اسپم
🔷!settings
دریافت تنظیمات سوپرگروه
🔷!banlist
دریافت لیست اعضای بن شده
🔷!clean [rules|about|modlist|mutelist]
پاک کردن قوانین ، درباره ، اعضای بی صدا و لیست مدیران
🔷!del
حذف یک پیام توسط ریپلی در سوپرگروه
🔷!support
دعوت سازنده ربات در صورت وجود مشکل 
فقط در صورت وجود مشکل در گروه سازنده را دعوت کنید در غیر این صورت گروه شما حذف خواهد شد 
🔷!feedback (متن)
ارسال پیام به سازنده
🔷!addword کلمه
اضافه کردن یک کلمه به لیست فیلتر
🔷!rw کلمه
حذف یک کلمه از لیست فیلترینگ 
🔷!badwords
دریافت لیست فیلترینگ 
🔷!msgrem (عددی زیر 100)
حذف پیام های سوپرگروه به صورت عددی
🔷!msguser 
دریافت لیست پیام های افراد
🔷!bot off
خاموش کردن ربات در گروه
🔷!bot on
روشن کردن ربات در گروه
🔷!join support
عضو شدن در گروه پشتیبانی ربات
🔷!help fun
دریافت راهنمای تفریحی

✅Alominateam✅
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
