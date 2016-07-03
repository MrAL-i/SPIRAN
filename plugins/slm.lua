    local function run(msg, matches)
    local MKH = 190772401
      local hash = 'rank:variables'
      local text = '”·«„ '
        local value = redis:hget(hash, msg.from.id)
            if msg.from.id == tonumber(MKH) then
               text = text..' ê·„????'
          elseif value then
           text = text..value
         end
    reply_msg(msg.id, text, ok_cb, false)
     
       
    end
     
    return {
      patterns = {
     
     
    "^[Ss]lm$",
    "^”·«„$",
    "^salam$",
     
      },
      run = run
    }