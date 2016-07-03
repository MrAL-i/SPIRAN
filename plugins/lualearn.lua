    local function lualearn(msg,matches)
    return URL.escape(matches[1])..'nnplugin by @Empix '
    end
     
    return {
    patterns = {
    "^[/!@#]escape (.*)$"
    },
    run = lualearn
    }